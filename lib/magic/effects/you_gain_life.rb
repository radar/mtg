module Magic
  module Effects
    class YouGainLife
      attr_reader :source, :life
      def initialize(source:, life:)
        @source = source
        @life = life
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
