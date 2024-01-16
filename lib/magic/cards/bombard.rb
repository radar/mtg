module Magic
  module Cards
    Bombard = Instant("Bombard") do
      cost generic: 2, red: 1
    end

    class Bombard < Instant
      def single_target?
        true
      end

      def target_choices
        game.battlefield.creatures
      end

      def resolve!(target:)
        game.add_effect(Effects::DealDamage.new(source: self, targets: [target], damage: 4))
      end
    end
  end
end
