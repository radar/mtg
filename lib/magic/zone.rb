module Magic
  class Zone
    extend Forwardable

    def_delegators :@cards, :include?, :select, :find, :count, :<<

    attr_reader :owner, :cards

    def initialize(owner:, cards: [])
      @owner = owner
      @cards = CardList.new(cards)
    end

    def add(card)
      card.zone = self
      self << card
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
