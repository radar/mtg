module Magic
  module Cards
    class Saga < Card
      class Chapter
        attr_reader :actor

        def initialize(actor:)
          @actor = actor
        end

        def name
          self.class.name.split("::").last
        end

        def resolve!
          resolve

          if final_chapter?
            card.game.notify!(Events::FinalChapterAbilityResolved, actor: actor)
            actor.sacrifice!
          end
        end

        def final_chapter?
          card.chapters.count == actor.counters.of_type(Counters::Lore).count
        end

        private

        def card
          actor.card
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
          game.stack.add(chapter_class.new(actor: actor))
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
