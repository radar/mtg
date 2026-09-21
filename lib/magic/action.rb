module Magic
  class Action
    include ResolvesWithArgs

    attr_reader :game, :player

    def initialize(game:, player:)
      @game = game
      @player = player
    end

    def can_perform?
      legal?
    end

    def illegal_reason
      nil
    end

    def legal?
      illegal_reason.nil?
    end

    private

    def sorcery_speed_reason
      turn = game.current_turn
      return "it is not #{player.inspect}'s turn" unless turn.active_player == player
      return "it is not a main phase" unless turn.main_phase?
      return "the stack is not empty" unless game.stack.empty?
    end
  end
end
