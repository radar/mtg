module Magic
  module Cards
    class Moonshadow < Creature
      card_name "Moonshadow"
      cost black: 1
      creature_type "Elemental"
      power 7
      toughness 7
      keywords :menace
      enters_with_counters "-1/-1", 6

      # "Whenever one or more permanent cards are put into your graveyard from anywhere while this
      # creature has a -1/-1 counter on it, remove a -1/-1 counter from this creature."
      # Cards that arrive together (a mill, a sweeper) all queue before any resolves, so only the
      # first one queues a trigger: one per batch, not one per card.
      class GraveyardTrigger < TriggeredAbility
        def should_perform?
          event.to.graveyard? && event.to.owner == controller && event.card.permanent? &&
            actor.counters.of_type(Counters::Minus1Minus1).any? && !already_queued?
        end

        def call
          actor.remove_counter(counter_type: Counters::Minus1Minus1)
        end

        private

        def already_queued?
          [*game.pending_triggers, *game.stack.abilities].any? { _1.is_a?(self.class) && _1.actor == actor }
        end
      end

      def event_handlers = { Events::CardEnteredZone => GraveyardTrigger }
    end
  end
end
