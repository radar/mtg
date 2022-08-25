module Magic
  module Effects
    class ChooseACard < Effect
      attr_reader :resolution

      def initialize(resolution:, **args)
        @resolution = resolution
        super(**args)
      end

      def requires_choices?
        true
      end

      def single_choice?
        false
      end

      def resolve(card)
        resolution.call(card)
      end
    end
  end
end
