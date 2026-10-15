module Magic
  module Cards
    FledglingDragon = Creature("Fledgling Dragon") do
      cost generic: 2, red: 2
      creature_type "Dragon"
      keywords :flying
      power 2
      toughness 2
    end

    class FledglingDragon < Creature
      THRESHOLD = 7

      # Threshold -- As long as there are seven or more cards in your graveyard, this creature gets +3/+3 ...
      class ThresholdBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 3, toughness: 3

        def applicable_targets = source.controller.graveyard.count >= THRESHOLD ? [source] : []
      end

      def static_abilities = [ThresholdBuff]

      # ... and has "{R}: This creature gets +1/+0 until end of turn."
      class FirebreathingAbility < Magic::ActivatedAbility
        costs "{R}"

        def requirements_met?
          source.controller.graveyard.count >= THRESHOLD
        end

        def resolve!
          pump(source, 1, 0)
        end
      end

      def activated_abilities = [FirebreathingAbility]
    end
  end
end
