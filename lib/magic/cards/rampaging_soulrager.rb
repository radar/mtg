module Magic
  module Cards
    RampagingSoulrager = Creature("Rampaging Soulrager") do
      cost generic: 2, red: 1
      creature_type "Spirit"
      power 1
      toughness 4
    end

    class RampagingSoulrager < Creature
      # "This creature gets +3/+0 as long as there are two or more unlocked doors among Rooms you control."
      class RoomBonus < Abilities::Static::PowerAndToughnessModification
        modify power: 3, toughness: 0

        conditions { source.controller.unlocked_doors.size >= 2 }
        applicable_targets { [source] }
      end

      def static_abilities = [RoomBonus]
    end
  end
end
