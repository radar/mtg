module Magic
  class Game
    extend Forwardable

    attr_reader :battlefield, :stack, :players, :step

    def_delegators :@stack, :effects, :add_effect, :resolve_effect

    def initialize(battlefield: Battlefield.new, stack: Stack.new, effects: [], players: [], step: Step.new(game: self))
      @step = step
      @battlefield = battlefield
      @stack = stack
      @effects = effects
      @players = players
    end

    def next_step
      step.next
    end

    def notify!(event)
      battlefield.notify!(event)
    end

    def active_player
      players.first
    end

    def change_active_player
      @players = players.rotate(1)
    end
  end
end
