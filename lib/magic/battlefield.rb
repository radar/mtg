module Magic
  class Battlefield < Zone
    attr_reader :cards

    def initialize(cards: [])
      @cards = CardList.new(cards)
    end

    def battlefield?
      true
    end

    def add(card)
      card.zone = self
      self.cards << card
    end

    def remove(card)
      @cards -= [card]
    end

    def receive_event(event)
      case event
      when Events::ZoneChange
        if event.to == :battlefield
          cards << event.card
        end

        if event.from == :battlefield
          self.cards -= [event.card]
        end
      end

      @cards.each { |card| card.receive_notification(event) }
    end

    def untap(&block)
      block.call(cards).each(&:untap!)
    end

    def creatures
      @cards.creatures
    end

    def creatures_controlled_by(player)
      @cards.creatures.controlled_by(player)
    end
  end
end
