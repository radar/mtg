module Magic
  # "Return it to the battlefield under its owner's control at the beginning of the next end step"
  # (optionally tapped, or with counters on it). A game-level listener that unsubscribes once it has
  # fired; cards no longer in exile by then (or tokens) stay where they are.
  #
  #   game.subscribe(DelayedReturn.new(game:, cards: [permanent.card], counters: { "+1/+1" => 1 }))
  #
  # "If it entered under your control, put a +1/+1 counter on <source>": pass `reward_for: player, reward_to: permanent`
  # (and optionally `reward_counter:`). Plain data rather than a lambda, so the game stays marshalable.
  class DelayedReturn
    def initialize(game:, cards:, counters: {}, enters_tapped: false, reward_for: nil, reward_to: nil, reward_counter: "+1/+1")
      @game = game
      @cards = cards
      @counters = counters
      @enters_tapped = enters_tapped
      @reward_for = reward_for
      @reward_to = reward_to
      @reward_counter = reward_counter
    end

    def receive_event(event)
      return unless event.is_a?(Events::BeginningOfEndStep)

      @game.unsubscribe(self)
      @cards.each do |card|
        next unless card.zone&.exile?

        permanent = card.resolve!(enters_tapped: @enters_tapped, controller: card.owner)
        next unless permanent

        @counters.each { |type, amount| permanent.add_counter(type, amount: amount) }
        reward! if permanent.controller == @reward_for
      end
    end

    private

    def reward!
      return unless @reward_to&.zone&.battlefield?

      @reward_to.add_counter(@reward_counter)
    end
  end
end
