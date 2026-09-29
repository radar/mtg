module Magic
  module Cards
    class FigureOfFable < Creature
      card_name "Figure of Fable"
      cost "{G/W}"
      creature_type "Kithkin"
      power 1
      toughness 1

      # The level of the permanent (0: none, 1: Scout, 2: Soldier, 3: Avatar), kept in its state.
      LEVELS = {
        1 => { types: %w[Scout], power: 2, toughness: 3 },
        2 => { types: %w[Soldier], power: 4, toughness: 5 },
        3 => { types: %w[Avatar], power: 7, toughness: 8 }
      }.freeze

      class Levels < Abilities::Static::CharacteristicSetting
        def applicable_targets = [source]

        def level = LEVELS[source.state[:level]]

        def set_types = level && [T::Creature, T::Creatures["Kithkin"], *level[:types].map { T::Creatures[_1] }]

        def set_base_power = level&.fetch(:power)

        def set_base_toughness = level&.fetch(:toughness)
      end

      # "{G/W}: This creature becomes a Kithkin Scout with base power and toughness 2/3."
      class ScoutAbility < Magic::ActivatedAbility
        costs "{G/W}"

        def resolve!
          source.state[:level] = 1
        end
      end

      # "{1}{G/W}{G/W}: If this creature is a Scout, it becomes a Kithkin Soldier with base power and
      # toughness 4/5."
      class SoldierAbility < Magic::ActivatedAbility
        costs "{1}{G/W}{G/W}"

        def resolve!
          source.state[:level] = 2 if source.state[:level] == 1
        end
      end

      # "{3}{G/W}{G/W}{G/W}: If this creature is a Soldier, it becomes a Kithkin Avatar with base power
      # and toughness 7/8 and protection from each of your opponents."
      class AvatarAbility < Magic::ActivatedAbility
        costs "{3}{G/W}{G/W}{G/W}"

        def resolve!
          return unless source.state[:level] == 2

          source.state[:level] = 3
          owner = controller
          source.protections << Protection.new(condition: ->(card) { card.respond_to?(:controller) && card.controller != owner })
        end
      end

      def static_abilities = [Levels]

      def activated_abilities = [ScoutAbility, SoldierAbility, AvatarAbility]
    end
  end
end
