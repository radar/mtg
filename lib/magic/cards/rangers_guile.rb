module Magic
  module Cards
    RangersGuile = Instant("Ranger's Guile") do
      cost green: 1
    end

    class RangersGuile < Instant
      def single_target?
        true
      end

      def target_choices
        controller.creatures
      end

      def resolve!(target:)
        target.modify_power(1)
        target.modify_toughness(1)
        target.grant_hexproof!
      end
    end
  end
end
