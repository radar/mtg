module Magic
  module Cards
    BaskingBroodscale = Creature("Basking Broodscale") do
      cost generic: 1, green: 1
      creature_type "Eldrazi Lizard"
      power 2
      toughness 2
      keywords :devoid
    end

    class BaskingBroodscale < Creature
      # "{1}{G}: Adapt 1." (If it has no +1/+1 counters on it, put a +1/+1 counter on it.)
      class AdaptAbility < Magic::ActivatedAbility
        costs "{1}{G}"

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source)
        end
      end

      # "You may create a 0/1 colorless Eldrazi Spawn creature token with 'Sacrifice this token: Add {C}.'"
      class SpawnChoice < Magic::Choice::May
        def prompt = "Create a 0/1 colorless Eldrazi Spawn creature token?"

        def resolve!
          create_eldrazi_spawn
        end
      end

      # "Whenever one or more +1/+1 counters are put on this creature, you may create an Eldrazi Spawn token."
      class CountersTrigger < TriggeredAbility::CounterAdded
        def should_perform?
          event.permanent == actor && Counters[event.counter_type] == Counters::Plus1Plus1
        end

        def call
          game.choices.add(SpawnChoice.new(actor: actor))
        end
      end

      def activated_abilities = [AdaptAbility]
      def event_handlers = { Events::CounterAddedToPermanent => CountersTrigger }
    end
  end
end
