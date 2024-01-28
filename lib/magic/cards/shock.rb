module Magic
  module Cards
    Shock = Instant("Shock") do
      cost red: 1

      def target_choices
        game.any_target
      end

      def single_target?
        true
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, damage: 2, target: target)
      end
    end
  end
end
