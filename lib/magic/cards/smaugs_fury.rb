module Magic
  module Cards
    SmaugsFury = Instant("Smaug's Fury") do
      cost generic: 1, red: 1
    end

    class SmaugsFury < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 3, 0)
        give_keyword(target, :reach)
        give_keyword(target, :first_strike)
      end
    end
  end
end
