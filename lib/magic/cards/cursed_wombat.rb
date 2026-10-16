module Magic
  module Cards
    CursedWombat = Creature("Cursed Wombat") do
      cost black: 1, green: 1
      creature_type "Nightmare Wombat"
      power 2
      toughness 3
    end

    class CursedWombat < Creature
      # "{2}{B}{G}: Adapt 2." (If it has no +1/+1 counters on it, put two +1/+1 counters on it.)
      class AdaptAbility < Magic::ActivatedAbility
        costs "{2}{B}{G}"

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source, amount: 2)
        end
      end

      # "Permanents you control have 'Whenever one or more +1/+1 counters are put on this permanent, put an additional
      # +1/+1 counter on it. This ability triggers only once each turn.'" The granted ability belongs to the permanent
      # that got the counters (event.permanent), and is tracked once per turn for each such permanent.
      class AdditionalCounterTrigger < TriggeredAbility::OncePerTurn
        def should_perform?
          event.permanent.controller == controller && Counters[event.counter_type] == Counters::Plus1Plus1
        end

        def call
          add_counter("+1/+1", to: event.permanent)
        end

        private

        # Each Wombat grants its own copy of the ability (CR 113.2c), so the once-per-turn key includes the source.
        def triggered_this_turn?
          event.permanent.triggered_once_this_turn?([self.class, actor])
        end

        def mark_triggered_this_turn!
          event.permanent.trigger_once_this_turn!([self.class, actor])
        end
      end

      def activated_abilities = [AdaptAbility]
      def event_handlers = { Events::CounterAddedToPermanent => AdditionalCounterTrigger }
    end
  end
end
