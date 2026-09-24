module Magic
  # Runs a block once, the next time a card moves to another zone, with the zone it
  # moved to. A "when this dies, return it to the battlefield" trigger runs as the
  # permanent leaves, before its card has been put into the graveyard, so it waits for
  # the card to get there (or to go somewhere else instead, such as exile).
  class OnCardMoved
    def self.listen(game:, card:, &block)
      new(game:, card:, &block).tap { game.subscribe(_1) }
    end

    def initialize(game:, card:, &block)
      @game = game
      @card = card
      @block = block
    end

    def receive_event(event)
      return unless event.is_a?(Events::CardEnteredZone) && event.card == @card

      @game.unsubscribe(self)
      @block.call(event.to)
    end
  end
end
