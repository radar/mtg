module Magic
  module Cards
    SnakeskinVeil = Instant("Snakeskin Veil") do
      cost green: 1
    end

    class SnakeskinVeil < Instant
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
        trigger_effect(:grant_keyword, target: target, keyword: :hexproof)
      end
    end
  end
end
