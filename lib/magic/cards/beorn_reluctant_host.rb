module Magic
  module Cards
    BeornReluctantHost = Creature("Beorn, Reluctant Host") do
      cost generic: 4, green: 1
      legendary_creature_type("Human Bear Shapeshifter")
      keywords :trample
      power 5
      toughness 5
    end

    class BeornReluctantHost < Creature
      # Till and Tend {1}{G}, Sorcery -- Adventure: "You may play an additional land this turn."
      adventure generic: 1, green: 1

      def adventure_resolve!(**)
        controller.grant_additional_land_this_turn!
      end
    end
  end
end
