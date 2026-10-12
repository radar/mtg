module Magic
  class Choice
    # "You may pay {1}{W}. If you do, ...": accepting (`game.resolve_choice!`, optionally with
    # `payment:` as for `Costs::Mana#pay!`, else paid automatically) pays the mana; declining
    # (`game.skip_choice!`) does nothing. The effects that follow "If you do" are run by a subclass
    # after `super`, so they never run when the choice is declined. Callers add it only when
    # `can_pay?`.
    class PayMana < Magic::Choice::May
      attr_reader :mana

      def initialize(actor:, mana:)
        @mana = mana
        super(actor: actor)
      end

      def can_pay? = Costs::Mana.new(mana).can_pay?(chooser)

      def resolve!(payment: nil)
        cost = Costs::Mana.new(mana)
        if payment
          cost.pay!(player: chooser, payment: payment)
        else
          cost.auto_pay(player: chooser)
          cost.finalize!(chooser)
        end
      end
    end
  end
end
