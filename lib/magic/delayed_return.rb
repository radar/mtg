module Magic
  # "Return it to the battlefield under its owner's control at the beginning of the next end step"
  # (optionally tapped, or with counters on it). A game-level listener that unsubscribes once it has
  # fired; cards no longer in exile by then (or tokens) stay where they are.
  #
  #   game.subscribe(DelayedReturn.new(game:, cards: [permanent.card], counters: { "+1/+1" => 1 }))
  class DelayedReturn
    def initialize(game:, cards:, counters: {}, enters_tapped: false)
      @game = game
      @cards = cards
      @counters = counters
      @enters_tapped = enters_tapped
    end

    def receive_event(event)
      return unless event.is_a?(Events::BeginningOfEndStep)

      @game.unsubscribe(self)
      @cards.each do |card|
        next unless card.zone&.exile?

        permanent = card.resolve!(enters_tapped: @enters_tapped, controller: card.owner)
        @counters.each { |type, amount| permanent.add_counter(type, amount: amount) } if permanent
      end
    end
  end
end
