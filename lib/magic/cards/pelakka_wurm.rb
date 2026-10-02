module Magic
  module Cards
    PelakkaWurm = Creature("Pelakka Wurm") do
      cost generic: 4, green: 3
      creature_type("Wurm")
      keywords :trample
      power 7
      toughness 7
    end

    class PelakkaWurm < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:gain_life, target: controller, life: 7)
        end
      end

      def etb_triggers = [EntersTrigger]

      class DiesTrigger < TriggeredAbility::Death
        def call
          trigger_effect(:draw_card)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
