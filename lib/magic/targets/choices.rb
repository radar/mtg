module Magic
  module Targets
    class Choices
      extend Forwardable

      attr_reader :choices, :min, :max

      def_delegators :choices, :select


      def initialize(choices:, min:, max:)
        @choices = choices
        @min = min
        @max = max
      end
    end
  end
end
