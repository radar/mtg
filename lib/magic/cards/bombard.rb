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
        creatures
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 4)
      end
    end
  end
end
