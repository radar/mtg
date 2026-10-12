module Magic
  module Cards
    ShrewdStoryteller = Creature("Shrewd Storyteller") do
      cost "{1}{G}{W}"
      creature_type "Human Survivor"
      power 3
      toughness 3
    end

    class ShrewdStoryteller < Creature
      class CounterChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target:, amount: 1)
        end
      end

      # "Survival — At the beginning of your second main phase, if this creature is tapped, put a +1/+1 counter on
      # target creature."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          game.add_choice(CounterChoice.new(actor:))
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
