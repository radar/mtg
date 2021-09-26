module Magic
  class Battlefield
    attr_reader :cards

    def initialize(cards: [])
      @cards = cards
    end

    def <<(card)
      card.cast!
      @cards << card
    end

    def creatures_controlled_by(player)
      @cards.select do |card|
        card.controller == player && card.creature?
      end
    end
  end
end
