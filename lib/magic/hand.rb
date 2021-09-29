module Magic
  class Hand < Zone
    def initialize(cards)
      @cards = cards
    end

    def hand?
      true
    end

    def add(card)
      card.zone = self
      @cards << card
    end

    def remove(card)
      @cards -= [card]
    end
  end
end
