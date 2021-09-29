module Magic
  class Zone
    extend Forwardable

    def_delegator :@cards, :include?

    attr_reader :cards

    def initialize(cards: [])
      @cards = CardList.new(cards)
    end

    def add(card)
      card.zone = self
      self.cards << card
    end

    def remove(card)
      @cards -= [card]
    end

    def library?
      false
    end

    def graveyard?
      false
    end

    def hand?
      false
    end

    def battlefield?
      false
    end

    def exile?
      false
    end
  end
end
