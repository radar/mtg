module Magic
  module Cards
    DefiantStrike = Instant("Defiant Strike") do
      cost white: 1
    end

    class DefiantStrike < Instant
      def target_choices
        battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(target:)
        if target.zone == battlefield
          pump target, 1
          controller.draw!
        end
      end
    end
  end
end
