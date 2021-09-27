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

    attr_reader :battlefield, :stack, :players, :effects

    def initialize(battlefield: Battlefield.new, stack: Stack.new, effects: [], players: [])
      @battlefield = battlefield
      @stack = stack
      @effects = effects
      @players = players
    end

    def add_to_battlefield(card)
      battlefield << card
    end

    def add_effect(effect)
      if effect.use_stack?
        @stack << effect
      else
        if effect.requires_choices?
          @effects << effect
          # wait for a choice to be made
        else
          effect.resolve
        end
      end
    end

    def resolve_effect(type, *args)
      effect = @effects.first
      if effect.is_a?(type)
        effect.resolve(*args)
        @effects.shift
      else
        raise "Invalid type specified. Top effect is a #{effect.class}, but you specified #{type}"
      end
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
