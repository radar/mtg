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
        deal_damage(2, to: target)
      end
    end
  end
end
