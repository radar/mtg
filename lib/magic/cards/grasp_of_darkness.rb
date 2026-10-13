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
        pump target, -4, -4
      end
    end
  end
end
