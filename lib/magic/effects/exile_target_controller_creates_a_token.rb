module Magic
  module Effects
    class ExileTargetControllerCreatesAToken < Effect
      attr_reader :choices, :token

      def initialize(choices:, token:)
        @choices = choices
        @token = token
      end

      def requires_choices?
        true
      end

      def single_choice?
        @choices.count == 1
      end

      def resolve(target:)
        target.exile!
        token.controller = target.controller
        token.resolve!
      end
    end
  end
end
