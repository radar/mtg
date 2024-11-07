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
        [
          *card.types,
          *permanent.attachments.flat_map(&:type_grants),
          *modifiers_by_type(Modifications::AdditionalType).flat_map(&:type_grants),
        ].uniq
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


      # attr_writer :types, :keywords, :power, :toughness


      # def type_grant_effects
      #   effects_by_type(Abilities::Static::TypeGrant)
      # end

      # def keyword_grant_effects
      #   effects_by_type(Abilities::Static::KeywordGrant)
      # end

      # def power_and_toughness_effects
      #   effects_by_type(Abilities::Static::PowerAndToughnessModification)
      # end

      # def power_grant_effects
      #   power_and_toughness_effects.select { |effect| effect.power_modification > 0 }
      # end

      # def counter_power_modifications
      #   permanent.counters.sum(&:power_modification)
      # end

      # def counter_toughness_modifications
      #   permanent.counters.sum(&:toughness_modification)
      # end

      # def toughness_grant_effects
      #   power_and_toughness_effects.select { |effect| effect.toughness_modification > 0 }
      # end

      # def effects_by_type(type)
      #   effects.select { |effect| effect.is_a?(type) }
      # end
    end
  end
end
