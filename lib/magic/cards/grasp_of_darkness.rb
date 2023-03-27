module Magic
  module Cards
    GraspOfDarkness = Instant("Grasp Of Darkness") do
      cost black: 2
    end

    class GraspOfDarkness < Instant
      def target_choices
        battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(controller, target:)
        effect = Effects::ApplyPowerToughnessModification.new(
          source: self,
          power: -4,
          toughness: -4,
          targets: target
        )
        game.add_effect(effect)

        super
      end
    end
  end
end
