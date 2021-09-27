module Magic
  class CardZone
    attr_reader :card

    def initialize(card)
      @card = card
    end

    include AASM

    aasm do
      state :library, initial: true
      state :hand
      state :battlefield
      state :graveyard
      state :exile

      event :draw do
        transitions from: :library, to: :hand
      end

      event :cast do
        transitions from: :hand, to: :stack
      end

      event :battlefield do
        transitions to: :battlefield, after: -> { card.entered_the_battlefield! }
      end

      event :graveyard do
        transitions to: :graveyard
      end

      event :move_to_graveyard do
        transitions from: :battlefield, to: :graveyard
      end
    end
  end
end
