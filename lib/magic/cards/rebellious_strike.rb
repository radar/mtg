module Magic
  module Cards
    RebelliousStrike = Instant("Rebellious Strike") do
      cost generic: 1, white: 1
    end

    class RebelliousStrike < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 3, 0)
        draw_card
      end
    end
  end
end
