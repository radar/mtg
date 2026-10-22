module Magic
  module Cards
    NaduWingedWisdom = Creature("Nadu, Winged Wisdom") do
      cost "{1}{G}{U}"
      legendary_creature_type "Bird Wizard"
      keywords :flying
      power 3
      toughness 4
    end

    class NaduWingedWisdom < Creature
      # Creatures you control have "Whenever this creature becomes the target of a spell or ability, reveal the top
      # card of your library. If it's a land card, put it onto the battlefield. Otherwise, put it into your hand.
      # This ability triggers only twice each turn."
      class TargetedTrigger < TriggeredAbility
        LIMIT = 2

        def should_perform?
          creature = event.permanent
          creature.creature? && creature.controller == controller && !limit_reached?(creature)
        end

        def trigger!
          return false unless should_perform?

          event.permanent.trigger_once_this_turn!([self.class, next_slot(event.permanent)])
          true
        end

        def call
          top = controller.library.first
          return unless top

          reveal_cards [top]
          if top.land?
            Permanent.put_onto_battlefield(card: top, game: game, from_zone: top.zone, controller: controller)
          else
            move_card top, to: controller.hand
          end
        end

        private

        def limit_reached?(creature) = next_slot(creature).nil?

        def next_slot(creature)
          LIMIT.times.find { |slot| !creature.triggered_once_this_turn?([self.class, slot]) }
        end
      end

      def event_handlers = super.merge(Events::BecameTarget => TargetedTrigger)
    end
  end
end
