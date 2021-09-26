module Magic
  class CardZone
    attr_reader :battlefield_entry_effects

    def initialize(battlefield_entry_effects: [])
      @battlefield_entry_effects = battlefield_entry_effects
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
        transitions from: :hand, to: :battlefield, after: :run_battlefield_entry_effects
      end

      event :move_to_graveyard do
        transitions from: :battlefield, to: :graveyard
      end
    end

    def run_battlefield_entry_effects
      battlefield_entry_effects.each(&:call)
    end
  end
end
