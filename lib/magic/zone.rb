module Magic
  class Zone
    extend Forwardable
    include Enumerable

    def_delegators :@cards, :each, :last, :shift, :unshift, :push, :empty?, :<<, :by_name, :creatures, :by_any_type, :basic_lands, :controlled_by, :cmc_lte, :by_card

    attr_reader :owner, :cards

    def initialize(owner:, cards: [])
      @owner = owner
      @cards = CardList.new(cards)
    end

    def to_s
      "#{self.class.name.split("::").last}"
    end
    alias_method :name, :to_s

    def add(card)
      card.zone = self
      @cards << card
    end

    def remove(card)
      @cards.delete(card)
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
