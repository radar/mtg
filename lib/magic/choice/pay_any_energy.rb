module Magic
  class Choice
    # "You may pay any amount of {E}. ... that much / for each {E} paid this way": answer with
    # `game.resolve_choice!(amount: n)` (default: all the energy the chooser has, clamped to 0..energy); declining
    # (`game.skip_choice!`) pays nothing, i.e. an amount of 0. A subclass overrides `paid(amount)` to apply the effect
    # that scales with the amount; it runs for 0 too.
    class PayAnyEnergy < Magic::Choice::May
      def max = chooser.energy

      def resolve!(amount: max)
        amount = amount.clamp(0, max)
        chooser.pay_energy!(amount)
        paid(amount)
      end

      def decline! = paid(0)

      def paid(amount)
      end
    end
  end
end
