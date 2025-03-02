module Magic
  class Zone
    extend Forwardable
    include Enumerable

    def_delegators :items, :each, :last, :shift, :unshift, :push, :empty?, :<<, :by_name, :creatures, :by_any_type, :basic_lands, :controlled_by, :cmc_lte, :by_card, :filter

    attr_reader :owner, :items

    def initialize(owner:, items: [])
      @owner = owner
      @items = CardList.new(items)
    end

    alias_method :cards, :items

    def to_s
      "#{self.class.name.split("::").last}"
    end
    alias_method :name, :to_s

    def supports?(item)
      true
    end

    def add(card, placement = 0)
      card.zone = self
      @items.insert(placement, card)
    end

    def remove(card)
      @items.delete(card)
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

    def lands
      cards.lands
    end
  end
end
