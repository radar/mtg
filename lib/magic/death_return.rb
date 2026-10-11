module Magic
  # Undying and persist (rules 702.93 and 702.79): "When this creature dies, if it had no +1/+1 (undying) or -1/-1
  # (persist) counters on it, return it to the battlefield under its owner's control with a +1/+1 (or -1/-1) counter on
  # it." Use as a card's `death_triggers`. The permanent that died still knows its counters (last known information). If
  # the trigger runs before the card reaches the graveyard, it waits for it there.
  module DeathReturn
    class Base < TriggeredAbility::Death
      def should_perform?
        actor.counters.of_type(opposite_counter).none? && !actor.token? && !actor.copy?
      end

      def call
        card = actor.card
        come_back = lambda do |zone|
          Permanent.put_onto_battlefield(game:, card:, owner: card.owner, from_zone: zone, counters: { counter_type => 1 })
        end

        return come_back.call(card.zone) if card.zone&.graveyard?

        OnCardMoved.listen(game:, card:) { |zone| come_back.call(zone) if zone.graveyard? }
      end
    end

    class Undying < Base
      def opposite_counter = Counters::Plus1Plus1
      def counter_type = "+1/+1"
    end

    class Persist < Base
      def opposite_counter = Counters::Minus1Minus1
      def counter_type = "-1/-1"
    end
  end
end
