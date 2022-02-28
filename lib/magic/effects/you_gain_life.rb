module Magic
  module Effects
    class YouGainLife < Effect
      attr_reader :life
      def initialize(life:, **args)
        @life = life
        super(**args)
      end

      def requires_choices?
        false
      end

      def resolve
        source.controller.gain_life(life)
      end
    end
  end
end
