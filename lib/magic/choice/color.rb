module Magic
  module Choice
    class Color
      attr_reader :callback
      def initialize(callback:)
        @callback = callback
      end

      def choose(color)
        @callback.call(color)
      end
    end
  end
end
