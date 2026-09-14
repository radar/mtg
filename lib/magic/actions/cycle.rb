module Magic
  module Actions
    class Cycle < Action
      attr_reader :card

      def initialize(card:, **args)
        @card = card
        super(**args)
      end

      def mana_cost
        @mana_cost ||= card.cycling_cost
      end

      def pay_mana(payment)
        mana_cost.pay(player: player, payment: payment)
        self
      end

      def can_perform?
        card.zone.hand? && mana_cost.can_pay?(player)
      end

      def perform
        mana_cost.finalize!(player)
        card.discard!
        card.trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end
  end
end
