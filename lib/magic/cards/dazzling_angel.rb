module Magic
  module Cards
    DazzlingAngel = Creature("Dazzling Angel") do
      cost generic: 2, white: 1
      creature_type("Angel")
      keywords :flying
      power 2
      toughness 3
    end

    class DazzlingAngel < Creature
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }
    end
  end
end
