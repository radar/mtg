module Magic
  module Cards
    BilbosDeadlySlice = Instant("Bilbo's Deadly Slice") do
      cost generic: 1, black: 2
    end

    class BilbosDeadlySlice < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
      end
    end
  end
end
