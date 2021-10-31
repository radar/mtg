module Magic
  class Game
    class Choices < SimpleDelegator
      def add(choice)
        self << choice
      end
    end
  end
end
