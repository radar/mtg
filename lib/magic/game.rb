module Magic
  class Game
    attr_reader :battlefield, :stack

    def initialize(battlefield: Battlefield.new, stack: Stack.new)
      @battlefield = battlefield
      @stack = stack
    end

    def add_to_battlefield(card)
      battlefield << card
    end
  end
end
