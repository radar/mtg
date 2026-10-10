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
        return unless cost.can_pay?(chooser)

        if payment
          cost.pay!(player: chooser, payment: payment)
        else
          cost.auto_pay(player: chooser)
          cost.finalize!(chooser)
        end
        actor.transform!
      end
    end
  end
end
