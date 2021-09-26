module Magic
  class Game
    attr_reader :battlefield

    def initialize(battlefield: Battlefield.new)
      @battlefield = battlefield
    end

    def add_to_battlefield(card)
      battlefield << card
    end
  end
end
