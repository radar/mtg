module Magic
  module Costs
    class AddCounter
      attr_reader :counter_type, :target

      def initialize(counter_type:, target:)
        @counter_type = counter_type
        @target = target
      end

      def finalize!(_player)
        target.add_counter(counter_type: counter_type)
      end
    end
  end
end
