module Magic
  module Cards
    NastyLittleRabbit = Creature("Nasty Little Rabbit") do
      cost green: 1
      creature_type("Rabbit")
      power 1
      toughness 2
    end

    class NastyLittleRabbit < Creature
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && (controller.creatures.any? { _1.power >= 4 })
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfCombat => BeginningOfCombatTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
