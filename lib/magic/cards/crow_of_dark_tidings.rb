module Magic
  module Cards
    CrowOfDarkTidings = Creature("Crow of Dark Tidings") do
      cost generic: 2, black: 1
      creature_type("Zombie Bird")
      keywords :flying
      power 2
      toughness 1
    end

    class CrowOfDarkTidings < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.mill(2)
        end
      end

      def etb_triggers = [EntersTrigger]

      class DiesTrigger < TriggeredAbility::Death
        def call
          controller.mill(2)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
