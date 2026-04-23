module Magic
  class Action
    include ResolvesWithArgs

    attr_reader :game, :player

    def initialize(game:, player:)
      @game = game
      @player = player
    end
  end
end
