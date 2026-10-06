module Magic
  module Cards
    class Saga < Card
      class ChapterAbility
        include BattlefieldFilters

        attr_reader :actor
        def initialize(actor:)
          @actor = actor
        end

        def trigger_effect(effect, **args)
          actor.trigger_effect(effect, **args)
        end

        def resolve!
          raise NotImplementedError
        end
      end

      type T::Enchantment, 'Saga'

      enters_the_battlefield do
        actor.trigger_effect(:add_counter, counter_type: "lore", target: actor)
      end

      class FirstMainPhaseTrigger < TriggeredAbility
        def should_perform?
          # A Saga that has transformed (Fable of the Mirror-Breaker's back face) is a creature now: no more chapters.
          event.active_player == controller && actor.card.respond_to?(:chapters)
        end

        def call
          actor.trigger_effect(:add_counter, counter_type: "lore", target: actor)
        end
      end

      class CounterAdded < TriggeredAbility::LoreCounterAdded
        def call
          return unless actor.card.respond_to?(:chapters)

          lore_counters = actor.counters.of_type(Magic::Counters::Lore).count

          # Read before resolving: a chapter may transform the Saga (Fable of the Mirror-Breaker), after which its
          # `card` is the back face, which has no chapters.
          chapters = actor.card.chapters
          chapter = chapters[lore_counters - 1]
          chapter.new(actor: actor).resolve!
          final = chapter == chapters.last

          game.notify!(Events::FinalChapterResolved.new(saga: actor)) if final

          # TODO: This must wait until the end of the resolution of the chapter
          # Rule 714.4. ... and it isn't the source of a chapter ability
          # that has triggered but not yet left the stack, ...
          # A Saga that transformed as its final chapter is a creature now: it is not sacrificed.
          if final && actor.card.respond_to?(:chapters)
            actor.trigger_effect(:sacrifice, source: actor, target: actor)
          end
        end
      end

      def event_handlers
        {
          Events::FirstMainPhase => FirstMainPhaseTrigger,
          Events::CounterAddedToPermanent => CounterAdded
        }
      end
    end
  end
end
