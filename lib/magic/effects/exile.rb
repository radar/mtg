module Magic
  module Effects
    class Exile < Effect
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
        target.exile!
      end
    end
  end
end
