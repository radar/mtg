module Magic
  module Cards
    BoulderDash = Sorcery("Boulder Dash") do
      cost generic: 1, red: 1
    end

    class BoulderDash < Sorcery
      def multi_target? = true

      def distinct_targets? = true

      def target_choices
        [game.any_target, game.any_target]
      end

      def resolve!(targets:)
        first, second = targets
        trigger_effect(:deal_damage, target: first, damage: 2)
        trigger_effect(:deal_damage, target: second, damage: 1)
      end
    end
  end
end
