module Magic
  module Cards
    FetidGargantua = Creature("Fetid Gargantua") do
      cost generic: 4, black: 1
      creature_type "Horror"
      power 4
      toughness 4
    end

    class FetidGargantua < Creature
      # "{2}{B}: Adapt 2." (If it has no +1/+1 counters on it, put two +1/+1 counters on it.)
      class AdaptAbility < Magic::ActivatedAbility
        costs "{2}{B}"

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source, amount: 2)
        end
      end

      # "You may draw two cards. If you do, you lose 2 life." Declining is `game.skip_choice!`.
      class DrawChoice < Magic::Choice::May
        def resolve!
          draw_cards 2
          lose_life controller, 2
        end
      end

      # "Whenever one or more +1/+1 counters are put on this creature, you may draw two cards. If you do, you lose 2 life."
      class CountersTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor && Counters[event.counter_type] == Counters::Plus1Plus1
        end

        def call
          game.add_choice(DrawChoice.new(actor:))
        end
      end

      def activated_abilities = [AdaptAbility]
      def event_handlers = { Events::CounterAddedToPermanent => CountersTrigger }
    end
  end
end
