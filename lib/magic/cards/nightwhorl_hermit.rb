module Magic
  module Cards
    NightwhorlHermit = Creature("Nightwhorl Hermit") do
      cost generic: 2, blue: 1
      creature_type("Rat Rogue")
      keywords :vigilance
      power 1
      toughness 4
    end

    class NightwhorlHermit < Creature
      # Threshold -- As long as there are seven or more cards in your graveyard, this creature gets +1/+0 and
      # can't be blocked.
      class ThresholdBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0

        def applicable_targets = source.controller.graveyard.count >= 7 ? [source] : []
      end

      def static_abilities = [ThresholdBuff]

      def can_be_blocked?(_blocker) = !(controller.graveyard.count >= 7)
    end
  end
end
