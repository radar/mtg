module Magic
  module Effects
    class MoveToBattlefield
      attr_reader :battlefield, :targets, :choices

      def initialize(battlefield:, maximum_choices:, choices:)
        @battlefield = battlefield
        @maximum_choices = maximum_choices
        @choices = choices
      end


      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def resolve(targets:)
        if targets.count > @maximum_choices
          raise "Too many targets chosen for Effects::MoveToBattlefield"
        end

        targets.each(&:resolve!)
      end
    end
  end
end
