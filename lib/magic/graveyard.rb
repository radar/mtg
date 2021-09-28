module Magic
  class Graveyard < Zone
    attr_reader :cards

    def initialize(player:, cards: [])
      @player = player
      @cards = CardList.new(cards)
    end

    def add(card)
      card.zone = self
      self.cards << card
    end

    def graveyard?
      true
    end
  end
end
