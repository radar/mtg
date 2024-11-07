module Magic
  module Cards
    WardedBattlements = Creature("Warded Battlements") do
      creature_type "Wall"
      cost generic: 2, white: 1

      power 0
      toughness 3

      keywords :defender

      class PowerBoost < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0

        applicable_targets { your.creatures.attacking }
      end

      def static_abilities = [PowerBoost]
    end
  end
end
