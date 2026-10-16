module Magic
  module Cards
    DreamdrinkerVampire = Creature("Dreamdrinker Vampire") do
      cost generic: 1, black: 1
      creature_type "Vampire"
      keywords :lifelink
      power 2
      toughness 1
    end

    class DreamdrinkerVampire < Creature
      # "{1}{B}: Adapt 1." (If it has no +1/+1 counters on it, put a +1/+1 counter on it.)
      class AdaptAbility < Magic::ActivatedAbility
        costs "{1}{B}"

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source)
        end
      end

      # "Whenever one or more +1/+1 counters are put on this creature, it gains menace until end of turn."
      class CountersTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor && Counters[event.counter_type] == Counters::Plus1Plus1
        end

        def call
          give_keyword(actor, :menace)
        end
      end

      def activated_abilities = [AdaptAbility]
      def event_handlers = { Events::CounterAddedToPermanent => CountersTrigger }
    end
  end
end
