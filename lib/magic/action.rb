module Magic
  class Action
    attr_reader :player, :game

    def initialize(player:)
      @player = player
      @game = player.game
    end
  end
end
