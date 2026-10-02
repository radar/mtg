module Magic
  module Cards
    KindledFury = Instant("Kindled Fury") do
      cost red: 1
    end

    class KindledFury < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target: target, power: 1, toughness: 0)
        trigger_effect(:grant_keyword, target: target, keyword: :first_strike)
      end
    end
  end
end
