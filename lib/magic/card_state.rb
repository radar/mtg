module Magic
  class CardState
    include AASM

    aasm do
      state :library, initial: true
      state :hand
      state :stack
      state :battlefield
      state :graveyard
      state :exile

      event :die do
        transitions from: :battlefield, to: :graveyard, after: -> { card.died! }
      end
    end

    attr_reader :card

    def initialize(card)
      @card = card
    end
  end
end
