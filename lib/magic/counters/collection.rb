module Magic
  module Counters
    class Collection < SimpleDelegator
      def of_type(type)
        select { |counter| counter.is_a?(type) }
      end

      def first_of_type(type, amount)
        __getobj__.select { |counter| counter.is_a?(type) }.first(amount)
      end

      def remove_first(type)
        index = __getobj__.index { |candidate| candidate.is_a?(type) }
        __getobj__.delete_at(index) if index
      end

      def delete(counter)
        __getobj__.delete(counter)
      end
    end
  end
end
