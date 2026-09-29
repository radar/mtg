module Magic
  module Permanents
    # Applies rule 613's layers, in order, recomputing every characteristic from
    # scratch each time (called after any mutation that could change one: entering
    # the battlefield, gaining/losing a modifier, cleanup, ...). Layers 1 and 2 are
    # resolved elsewhere (Permanent#copiable_card/#copied_card and
    # Permanent#controller=/#gain_control_until_eot! respectively -- both already
    # apply eagerly rather than being recomputed here) and are only labelled below
    # so the pipeline documents all seven layers rather than silently skipping two.
    #
    # 613.8 dependency ordering within a layer/sublayer isn't implemented -- ties
    # are broken by timestamp only (613.7: a static ability's effect is timestamped
    # to when its source entered the battlefield; a one-shot modifier, to when it
    # was created -- see ContinuousEffect.next_timestamp). `last_by_timestamp`
    # below is the hook a future dependency pass would replace.
    class ContinuousEffects
      extend Forwardable

      def_delegators :@permanent, :card, :copiable_card

      attr_reader :game, :permanent, :controller

      def initialize(game:, permanent:)
        @game = game
        @permanent = permanent
      end

      # 613.7, layer 7b: the resolved base power/toughness (before 7c modifiers,
      # counters and attachments) -- exposed publicly so Permanent#base_power/
      # #base_toughness (e.g. Zinnia, Valley's Voice's "base power 1" count) share
      # the same timestamp-ordered resolution as #calculate_power/#calculate_toughness,
      # rather than a second, characteristic-setting-blind implementation.
      def base_power
        last_by_timestamp(
          modifiers_by_type(Modifications::BasePower).map { [_1.timestamp, _1.base_power] } +
          characteristic_settings.select(&:set_base_power).map { [_1.timestamp, _1.set_base_power] },
        ) || (copiable_card.base_power if copiable_card.respond_to?(:base_power)) || 0
      end

      def base_toughness
        last_by_timestamp(
          modifiers_by_type(Modifications::BaseToughness).map { [_1.timestamp, _1.base_toughness] } +
          characteristic_settings.select(&:set_base_toughness).map { [_1.timestamp, _1.set_base_toughness] },
        ) || (copiable_card.base_toughness if copiable_card.respond_to?(:base_toughness)) || 0
      end

      def apply!
        game.logger.debug "Applying continuous effects for #{permanent}"

        # Layer 1 (copy): Permanent#copiable_card already resolves copy effects
        # for every characteristic below.
        # Layer 2 (control): applied eagerly by Permanent#gain_control_until_eot!/
        # #controller=, not recomputed here.

        # Layer 3 (text-changing, e.g. "loses all abilities")
        permanent.lost_all_abilities_by_effect = characteristic_settings.any?(&:loses_all_abilities?)

        # Layer 4 (type-changing)
        types = calculate_types
        permanent.types = types
        game.logger.debug "Types: #{types}"

        # Layer 5 (colour-changing)
        permanent.color_override = calculate_color

        # Layer 6 (ability add/remove)
        permanent.activated_abilities = calculate_activated_abililities
        permanent.keywords = calculate_keywords
        game.logger.debug "Keywords: #{permanent.keywords}"

        # Layer 7: power/toughness (7a characteristic-defining, 7b set, 7c modify
        # incl. counters, 7d switch)
        if creature?(types)
          power = calculate_power
          toughness = calculate_toughness
          power, toughness = toughness, power if switch_power_and_toughness?
          permanent.power = power
          game.logger.debug "Power: #{permanent.power}"
          permanent.toughness = toughness
          game.logger.debug "Toughness: #{permanent.toughness}"
        end
      end

      private

      def static_abilities
        StaticAbilities.new(game.battlefield.static_abilities.to_a + graveyard_static_abilities + emblem_static_abilities)
      end

      def emblem_static_abilities
        game.emblems.flat_map { |emblem| emblem.static_abilities.map { |ability| ability.new(source: emblem) } }
      end

      def graveyard_static_abilities
        game.players.flat_map do |player|
          player.graveyard.cards.flat_map do |card|
            card.graveyard_static_abilities.map { |ability| ability.new(source: card) }
          end
        end
      end

      def creature?(types)
        types.include?(T::Creature)
      end

      # 613.7: among effects competing to set the same layer-7b value, the one
      # with the latest timestamp wins. `entries` is a list of `(timestamp, value)`
      # pairs; nil values (no setter present) are already filtered by the callers.
      def last_by_timestamp(entries)
        entries.max_by(&:first)&.last
      end

      def calculate_power
        [
          permanent.counters,
          modifiers_by_type(Modifications::Power),
          power_toughness_static_abilities,
          permanent.attachments,
        ]
          .flatten
          .sum(base_power) do |modification|
            modification.power_modification
          end
      end

      def calculate_toughness
        [
          permanent.counters,
          modifiers_by_type(Modifications::Toughness),
          power_toughness_static_abilities,
          permanent.attachments,
        ]
          .flatten
          .sum(base_toughness) do |modification|
            modification.toughness_modification
          end
      end

      def switch_power_and_toughness?
        # Multiple switches commute -- only parity matters.
        modifiers_by_type(Modifications::SwitchPowerToughness).count.odd?
      end

      def modifiers_by_type(type)
        permanent.modifiers.select { |modifier| modifier.is_a?(type) }
      end

      def calculate_types
        base_types = last_by_timestamp(characteristic_settings.select(&:set_types).map { [_1.timestamp, _1.set_types] }) || copiable_card.types
        types = [
          *base_types,
          *permanent.attachments.flat_map(&:type_grants),
          *static_abilities_for(permanent).of_type(Abilities::Static::TypeGrant).flat_map(&:type_grants),
          *modifiers_by_type(Modifications::AdditionalType).flat_map(&:type_grants),
        ]

        types = types.uniq
        types -= Magic::Types::Creatures.values if modifiers_by_type(Modifications::LoseCreatureTypes).any?
        types -= static_abilities_for(permanent).of_type(Abilities::Static::TypeRemoval).flat_map(&:type_removal)
      end

      def calculate_color
        last_by_timestamp(
          modifiers_by_type(Modifications::Color).map { [_1.timestamp, _1.colors] } +
          characteristic_settings.select(&:set_colors).map { [_1.timestamp, _1.set_colors] },
        )
      end

      def calculate_keywords
        [
          *(permanent.lost_all_abilities? ? [] : copiable_card.keywords),
          *keyword_grant_static_abilities.flat_map { _1.keyword_grants_for(permanent) },
          *modifiers_by_type(Modifications::KeywordGrant).map(&:keyword_grant),
          *permanent.attachments.flat_map(&:keyword_grants),
          *permanent.counters.filter_map { _1.keyword if _1.respond_to?(:keyword) },
        ]
      end

      def characteristic_settings
        static_abilities_for(permanent).of_type(Abilities::Static::CharacteristicSetting)
      end

      def power_toughness_static_abilities
        static_abilities_for(permanent).of_type(Abilities::Static::PowerAndToughnessModification)
      end

      def keyword_grant_static_abilities
        static_abilities_for(permanent).of_type(Abilities::Static::KeywordGrant)
      end

      def static_abilities_for(permanent)
        static_abilities.applies_to(permanent)
      end

      def calculate_activated_abililities
        class_types = permanent.lost_all_abilities? ? [] : permanent.types.select { |type| type.is_a?(Class) }
        [
          *(permanent.lost_all_abilities? ? [] : copiable_card.activated_abilities),
          # Land types specifically give one mana ability each
          *class_types.flat_map { |type| type::ManaAbility},
          *granted_activated_abilities,
        ]
        .map do |ability|
          ability.new(source: permanent)
        end
      end

      def granted_activated_abilities
        static_abilities_for(permanent)
          .of_type(Abilities::Static::GrantActivatedAbilities)
          .flat_map(&:granted_abilities)
      end
    end
  end
end
