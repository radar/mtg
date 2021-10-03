module Magic
  module Effects
    class MoveToBattlefield
      attr_reader :battlefield, :targets, :choices

      def initialize(battlefield:, targets:, choices:)
        @battlefield = battlefield
        @targets = targets
        @choices = choices
      end


      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def resolve(targets:)
        targets.each(&:resolve!)
      end
    end
  end
end
