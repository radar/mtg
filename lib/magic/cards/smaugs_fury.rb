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
        trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 0)
        trigger_effect(:grant_keyword, target: target, keyword: :reach)
        trigger_effect(:grant_keyword, target: target, keyword: :first_strike)
      end
    end
  end
end
