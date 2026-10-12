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
        deal_damage(2, to: first)
        deal_damage(1, to: second)
      end
    end
  end
end
