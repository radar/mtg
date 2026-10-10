module Magic
  class Choice
    # "You may pay {X}. When you do, ...": accepting with `game.resolve_choice!(x: 3)` pays {3} from the
    # mana pool (automatically) and remembers it as `x` for the effects that follow, which a subclass
    # runs after `super`. Declining (`game.skip_choice!`) does nothing. Callers add it only when
    # something can be paid (`can_pay?`).
    class PayX < Magic::Choice::May
      attr_reader :x

      def can_pay? = Costs::Mana.new(generic: 1).can_pay?(chooser)

      def resolve!(x: 0)
        @x = x
        return if x.zero?

        cost = Costs::Mana.new(generic: x)
        cost.auto_pay(player: chooser)
        cost.finalize!(chooser)
      end
    end
  end
end
