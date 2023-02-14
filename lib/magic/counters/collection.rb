module Magic
  module Counters
    class Collection < SimpleDelegator
      def of_type(type)
        select { |counter| counter.is_a?(type) }
      end
    end
  end
end
