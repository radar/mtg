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
        trigger_effect(:modify_power_toughness, target: target, power: 1, toughness: 3)
        trigger_effect(:grant_keyword, target: target, keyword: :reach)
        target.untap!
      end
    end
  end
end
