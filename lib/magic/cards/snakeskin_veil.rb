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
        add_counter("+1/+1", to: target)
        give_keyword(target, :hexproof)
      end
    end
  end
end
