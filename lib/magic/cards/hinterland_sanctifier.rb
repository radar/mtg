module Magic
  module Cards
    HinterlandSanctifier = Creature("Hinterland Sanctifier") do
      cost white: 1
      creature_type("Rabbit Cleric")
      power 1
      toughness 2
    end

    class HinterlandSanctifier < Creature
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
