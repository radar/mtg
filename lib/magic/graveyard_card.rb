module Magic
  class GraveyardCard
    attr_reader :card

    def initialize(card:)
      @card = card
    end

    def inspect
      "#<GraveyardCard name:#{name}>"
    end

    def activated_abilities
      @card.activated_abilities.map { |ability| ability.new(source: card) }
    end

    def method_missing(name, *args, &block)
      @card.send(name, *args, &block)
    end
  end
end
