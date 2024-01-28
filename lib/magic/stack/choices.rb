module Magic
  class Stack
    class Choices < SimpleDelegator
      def add(choice)

        self << choice
      end
    end
  end
end
