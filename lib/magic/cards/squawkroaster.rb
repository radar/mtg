module Magic
  module Cards
    Squawkroaster = Creature("Squawkroaster") do
      creature_type "Elemental"
      cost generic: 3, red: 1
      toughness 4
      keywords :double_strike
    end

    class Squawkroaster < Creature
      # Vivid -- Squawkroaster's power is equal to the number of colors among permanents you control.
      class DynamicPower < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification = source.controller.colors_among_permanents

        def toughness_modification = 0
      end

      def static_abilities = [DynamicPower]
    end
  end
end
