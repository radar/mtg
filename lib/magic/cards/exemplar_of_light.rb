module Magic
  module Cards
    ExemplarOfLight = Creature("Exemplar of Light") do
      cost generic: 2, white: 2
      creature_type("Angel")
      keywords :flying
      power 3
      toughness 3
    end

    class ExemplarOfLight < Creature
      class LifeGainTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      class CountersPutOnThisTrigger < TriggeredAbility::OncePerTurn
        def should_perform?
          event.permanent == actor && Counters[event.counter_type] == Counters::Plus1Plus1 && (event.source.nil? || event.source.controller == controller)
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = { Events::LifeGain => LifeGainTrigger, Events::CounterAddedToPermanent => CountersPutOnThisTrigger }
    end
  end
end
