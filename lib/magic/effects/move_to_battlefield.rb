module Magic
  module Effects
    class MoveToBattlefield < Effect
      attr_reader :battlefield, :controller, :targets, :choices

      def initialize(battlefield:, controller:, maximum_choices:, choices:)
        @battlefield = battlefield
        @controller = controller
        @maximum_choices = maximum_choices
        @choices = choices
        @targets = []
      end

      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def no_choice?
        choices.count == 0
      end

      def resolve(targets)
        if targets.count > @maximum_choices
          raise "Too many targets chosen for Effects::MoveToBattlefield"
        end

        targets.each { |target| target.resolve! }
        super
      end
    end
  end
end
