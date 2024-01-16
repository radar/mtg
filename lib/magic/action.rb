module Magic
  class Action
    attr_reader :game, :player

    def initialize(game:, player:)
      @game = game
      @player = player
    end
  end
end
