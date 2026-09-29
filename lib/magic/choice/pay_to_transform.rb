module Magic
  class Choice
    # "You may pay {R}. If you do, transform ~." Answer with `payment:` (mana as in
    # `Costs::Mana#pay`; without it the mana is paid automatically). Declining, or being unable
    # to pay, leaves the permanent as it is.
    class PayToTransform < Magic::Choice::May
      attr_reader :mana

      def initialize(actor:, mana:)
        @mana = mana
        super(actor: actor)
      end

      def resolve!(payment: nil)
        cost = Costs::Mana.new(mana)
        return unless cost.can_pay?(controller)

        if payment
          cost.pay!(player: controller, payment: payment)
        else
          cost.auto_pay(player: controller)
          cost.finalize!(controller)
        end
        actor.transform!
      end
    end
  end
end
