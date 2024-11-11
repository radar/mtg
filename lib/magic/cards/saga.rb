module Magic
  module Cards
    class Saga < Card
      class Chapter
        attr_reader :actor

        def initialize(actor:)
          @actor = actor
        end
      end

      type T::Enchantment, "Saga"

      enters_the_battlefield do
        actor.trigger_effect(:add_counter, counter_type: Counters::Lore, target: actor)
      end

      class CounterAddedTrigger < TriggeredAbility
        def should_perform?
          this? && event.counter_type == Counters::Lore
        end

        def call
          lore_counters = actor.counters.of_type(Counters::Lore)
          chapter_class = card.chapter(lore_counters)
          chapter_class.new(actor: actor).start

          actor.sacrifice! if card.chapters.count == lore_counters.count
        end
      end

      class FirstMainPhaseTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          actor.trigger_effect(:add_counter, counter_type: Counters::Lore, target: actor)
        end
      end

      def chapter(counters)
        chapters[counters.count - 1]
      end

      def chapters
        raise NotImplementedError
      end

      def event_handlers
        {
          Events::CounterAddedToPermanent => CounterAddedTrigger,
          Events::FirstMainPhaseStarted => FirstMainPhaseTrigger,
        }
      end
    end
  end
end
