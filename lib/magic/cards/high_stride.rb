module Magic
  module Cards
    HighStride = Instant("High Stride") do
      cost green: 1
    end

    class HighStride < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 1, 3)
        give_keyword(target, :reach)
        target.untap!
      end
    end
  end
end
