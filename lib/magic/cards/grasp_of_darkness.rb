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

      def resolve!(target:)
        target.modify_power_toughness!(source: self, power: -4, toughness: -4)

        super
      end
    end
  end
end
