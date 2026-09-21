module Magic
  class Action
    include ResolvesWithArgs

    attr_reader :game, :player

    def initialize(game:, player:)
      @game = game
      @player = player
    end

    # Why this action cannot be taken right now (timing, zone, limits), or nil if it can.
    # Checked by Turn#take_action just before #perform, i.e. after any costs have been
    # paid, so it must not check whether costs are payable; see #can_perform? for that.
    def illegal_reason
      nil
    end

    def legal?
      illegal_reason.nil?
    end

    private

    # Rule 307.1 / 601.3: sorcery-speed actions need an empty stack in the active
    # player's main phase.
    def sorcery_speed_reason
      turn = game.current_turn
      return "it is not #{player.inspect}'s turn" unless turn.active_player == player
      return "it is not a main phase" unless turn.main_phase?
      return "the stack is not empty" unless game.stack.empty?
    end
  end
end
