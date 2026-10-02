module Magic
  module Cards
    WardenOfTheGrove = Creature("Warden of the Grove") do
      cost generic: 2, green: 1
      creature_type("Hydra")
      power 2
      toughness 2
    end

    class WardenOfTheGrove < Creature
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step?
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      class NontokenCreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? && !event.permanent.token?
        end

        def call
          game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: actor.counters.count, creature: event.permanent))
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger, Events::EnteredTheBattlefield => NontokenCreatureEntersTrigger }
    end
  end
end
