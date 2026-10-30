module Magic
  class Stack
    class Choices < SimpleDelegator
      # The owning Stack, so a choice added straight through `game.choices.add` (most cards do) still reaches the
      # stack's observer.
      attr_accessor :stack

      def add(choice)
        unshift(choice)
        stack&.observer&.added(choice)
      end
    end
  end
end
