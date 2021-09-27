module Magic
  class Game
    include AASM

    aasm do
      state :untap, initial: true, after_enter: :untap_active_player_permanents
      state :upkeep
      state :draw, after_enter: -> { active_player.draw! }

      event :upkeep do
        transitions from: :untap, to: :upkeep
      end

      event :draw do
        transitions from: :upkeep, to: :draw
      end

      event :cleanup do
        transitions to: :untap, after: :change_active_player
      end
    end

    attr_reader :battlefield, :stack, :players

    def initialize(battlefield: Battlefield.new, stack: Stack.new, players: [])
      @battlefield = battlefield
      @stack = stack
      @players = players
    end

    def add_to_battlefield(card)
      battlefield << card
    end

    def active_player
      players.first
    end

    def change_active_player
      @players = players.rotate(1)
    end

    def untap_active_player_permanents
      battlefield.untap { |cards| cards.controlled_by(active_player) }
    end
  end
end
