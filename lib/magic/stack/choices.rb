module Magic
  class Stack
    class Choices < SimpleDelegator
      def add(choice)
        unshift(choice)
      end
    end
  end
end
