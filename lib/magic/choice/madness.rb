module Magic
  class Choice
    # Madness (rule 702.35): a card with madness that is discarded is exiled instead; its owner may then cast it for
    # its madness cost. Declining (or being unable to pay) puts it into the graveyard. `Card#discard!` starts this.
    class Madness < Magic::Choice::May
      attr_reader :card

      def initialize(actor:, card:)
        @card = card
        super(actor: actor)
      end

      def prompt = "Cast #{card.name} for its madness cost?"

      def resolve!
        cost = card.madness_cost
        return decline! unless card.zone&.exile?

        card.owner.cast(card: card, by_effect: true) do |action|
          action.mana_cost = cost
          action.pay_mana(cost)
        end
      rescue Magic::IllegalAction, Magic::Costs::Mana::CannotPay
        decline!
      end

      def decline!
        card.move_zone!(to: card.owner.graveyard) if card.zone&.exile?
      end
    end
  end
end
