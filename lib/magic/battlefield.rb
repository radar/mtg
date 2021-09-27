module Magic
  class Battlefield
    attr_reader :cards

    def initialize(cards: [])
      @cards = CardList.new(cards)
    end

    def <<(card)
      card.cast!
      @cards << card
    end

    def untap(&block)
      block.call(cards).each(&:untap!)
    end

    def creatures_controlled_by(player)
      @cards.controlled_by(player).select(&:creature?)
    end
  end
end
