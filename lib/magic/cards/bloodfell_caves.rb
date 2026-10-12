module Magic
  module Cards
    class BloodfellCaves < Land
      NAME = "Bloodfell Caves"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      def activated_abilities = [ManaAbility]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_life(1)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
