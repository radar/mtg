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

      def resolve!(controller, target:)
        if target.zone == battlefield
          game.add_effect(Effects::ApplyPowerToughnessModification.new(source: self, power: 1, targets: target))
          controller.draw!
        end

        super
      end
    end
  end
end
