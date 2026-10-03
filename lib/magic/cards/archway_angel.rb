module Magic
  module Cards
    ArchwayAngel = Creature("Archway Angel") do
      cost generic: 5, white: 1
      creature_type("Angel")
      keywords :flying
      power 3
      toughness 4
    end

    class ArchwayAngel < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:gain_life, target: controller, life: 2 * controller.permanents.by_type("Gate").count)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
