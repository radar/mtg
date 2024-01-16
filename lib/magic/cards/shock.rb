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
        game.add_effect(Effects::DealDamage.new(source: self, targets: [target], damage: 2))
      end
    end
  end
end
