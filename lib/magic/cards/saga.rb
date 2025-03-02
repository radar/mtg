module Magic
  module Cards
    class Saga < Card
      class ChapterAbility
        attr_reader :actor
        def initialize(actor:)
          @actor = actor
        end

        def resolve!
          raise NotImplementedError
        end
      end

      type T::Enchantment, 'Saga'

      enters_the_battlefield do
        actor.trigger_effect(:add_counter, counter_type: Magic::Counters::Lore, target: actor)
      end

      class CounterAdded < TriggeredAbility::LoreCounterAdded
        def should_perform?
          super
        end

        def call
          lore_counters = actor.counters.of_type(Magic::Counters::Lore).count

          chapter = actor.card.chapters[lore_counters - 1]
          chapter.new(actor: actor).resolve!

          # TODO: This must wait until the end of the resolution of the chapter
          # Rule 714.4. ... and it isn't the source of a chapter ability
          # that has triggered but not yet left the stack, ...
          if chapter == actor.card.chapters.last
            actor.trigger_effect(:sacrifice, source: actor, target: actor)
          end
        end
      end

      def event_handlers
        {
          Events::CounterAddedToPermanent => CounterAdded
        }
      end
    end
  end
end
