module Magic
  class Choice
    # "You may pay {E}. If you do, ...": accepting (`game.resolve_choice!`) pays the energy; declining
    # (`game.skip_choice!`) does nothing. The effects that follow "If you do" are run by a subclass after `super`, so
    # they never run when the choice is declined. Callers add it only when `can_pay?`. Like Choice::PayMana.
    class PayEnergy < Magic::Choice::May
      attr_reader :amount

      def initialize(actor:, amount: 1)
        @amount = amount
        super(actor: actor)
      end

      def can_pay? = chooser.energy >= amount

      def resolve!
        chooser.pay_energy!(amount)
      end
    end
  end
end
