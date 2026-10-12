module Magic
  module Cards
    class GraypeltRefuge < Land
      NAME = "Graypelt Refuge"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
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
