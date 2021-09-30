module Magic
  module Effects
    class Destroy < Effect
      attr_reader :choices

      def initialize(choices:)
        @choices = choices
        super()
      end

      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def resolve(target:)
        target.destroy!
      end
    end
  end
end
