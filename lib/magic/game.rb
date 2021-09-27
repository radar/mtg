module Magic
  class Game
    attr_reader :battlefield, :stack, :players, :effects, :step

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

    def resolve_effect(type, **args)
      effect = @effects.first
      if effect.is_a?(type)
        effect.resolve(**args)
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
  end
end
