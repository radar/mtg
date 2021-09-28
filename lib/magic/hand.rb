module Magic
  class Hand < Zone
    def initialize(cards)
      @cards = cards
    end

    def add(card)
      @cards << card
    end

    def remove(card)
      @cards -= [card]
    end
  end
end
