module Magic
  module Cards
    LavaDart = Instant("Lava Dart") do
      cost red: 1
    end

    class LavaDart < Instant
      def flashback_cost
        Costs::SacrificeAlternativeCost.new(-> (permanent) { permanent.type?("Mountain") })
      end

      def single_target?
        true
      end

      def target_choices
        game.any_target
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, damage: 1, target: target)
      end
    end
  end
end
