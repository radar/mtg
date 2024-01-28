module Magic
  module Targets
    class Choices
      extend Forwardable

      attr_reader :choices, :min, :max

      def_delegators :choices, :select, :include?, :first, :count, :-

      def initialize(choices:, min: 1, max: 1)
        @choices = choices
        @min = min
        @max = max
      end
    end
  end
end
