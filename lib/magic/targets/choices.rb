module Magic
  module Targets
    class Choices
      extend Forwardable

      attr_reader :choices, :min, :max

      def_delegators :choices, :select, :include?, :first, :count, :-

      def initialize(choices:, amount:)
        @choices = choices
        if amount.is_a?(Range)
          @min = amount.first
          @max = amount.last
        else
          @min = amount
          @max = amount
        end

      end
    end
  end
end
