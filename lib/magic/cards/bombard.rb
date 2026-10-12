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
        deal_damage(4, to: target)
      end
    end
  end
end
