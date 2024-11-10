module Magic
  module Permanents
    class ContinuousEffects
      extend Forwardable

      def_delegators :@permanent, :card

      attr_reader :game, :permanent, :controller

      def initialize(game:, permanent:)
        @game = game
        @permanent = permanent
      end

      def apply!
        game.logger.debug "Applying continuous effects for #{permanent}"
        # Layer 4
        types = calculate_types

        permanent.types = types
        game.logger.debug "Types: #{types}"
        # Layer 6
        permanent.activated_abilities = calculate_activated_abililities
        permanent.keywords = calculate_keywords
        game.logger.debug "Keywords: #{permanent.keywords}"
        # Layer 7
        if creature?(types)
          permanent.power = calculate_power
          game.logger.debug "Power: #{permanent.power}"
          permanent.toughness = calculate_toughness
          game.logger.debug "Toughness: #{permanent.toughness}"
        end
      end

      private

      def static_abilities
        game.battlefield.static_abilities
      end

      def creature?(types)
        types.include?(T::Creature)
      end

      def calculate_power
        base_power = modifiers_by_type(Modifications::BasePower).last&.base_power || card.base_power
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
        base_toughness = modifiers_by_type(Modifications::BaseToughness).last&.base_toughness || card.base_toughness
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

      def modifiers_by_type(type)
        permanent.modifiers.select { |modifier| modifier.is_a?(type) }
      end

      def calculate_types
        types = [
          *card.types,
          *permanent.attachments.flat_map(&:type_grants),
          *static_abilities_for(permanent).of_type(Abilities::Static::TypeGrant).flat_map(&:type_grants),
          *modifiers_by_type(Modifications::AdditionalType).flat_map(&:type_grants),
        ]

        types -= static_abilities_for(permanent).of_type(Abilities::Static::TypeRemoval).flat_map(&:type_removal)
      end

      def calculate_keywords
        [
          *card.keywords,
          *keyword_grant_static_abilities.flat_map(&:keyword_grants),
          *modifiers_by_type(Modifications::KeywordGrant).map(&:keyword_grant),
          *permanent.attachments.flat_map(&:keyword_grants),
        ]
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
        class_types = permanent.types.select { |type| type.is_a?(Class) }
        [
          *card.activated_abilities,
          # Land types specifically give one mana ability each
          *class_types.flat_map { |type| type::ManaAbility},
        ]
        .map do |ability|
          ability.new(source: permanent)
        end
      end
    end
  end
end
