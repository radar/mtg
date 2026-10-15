module Magic
  module Cards
    WingIt = Instant("Wing It") do
      cost generic: 1, white: 1
    end

    class WingIt < Instant
      def target_choices
        battlefield.creatures
      end

      # "Target creature gets +2/+2 until end of turn. Put a flying counter on it. Scry 1."
      def resolve!(target:)
        pump(target, 2, 2)
        add_counter("flying", to: target)
        game.choices.add(Magic::Choice::Scry.new(actor: controller, amount: 1))
      end
    end
  end
end
