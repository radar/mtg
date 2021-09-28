module Magic
  class Library
    attr_reader :cards

    def initialize(cards)
      @cards = cards
    end

    def remove(card)
      @cards -= [card]
    end

    def draw
      @cards.shift
    end
  end
end
