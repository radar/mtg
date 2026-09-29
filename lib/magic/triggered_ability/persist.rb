module Magic
  class TriggeredAbility
    # Persist (rule 702.79): "When this permanent is put into a graveyard from the battlefield, if
    # it had no -1/-1 counters on it, return it to the battlefield under its owner's control with
    # a -1/-1 counter on it." Added by `Permanent` when a dying creature has the keyword, whether
    # printed or granted (Isilu, Carrier of Twilight).
    class Persist < TriggeredAbility
      def should_perform?
        event.permanent == actor && actor.counters.of_type(Counters::Minus1Minus1).none?
      end

      def call
        card = actor.card
        return unless card.zone&.graveyard?

        returned = card.resolve!(controller: card.owner)
        returned.add_counter(Counters::Minus1Minus1) if returned.is_a?(Permanent)
      end
    end
  end
end
