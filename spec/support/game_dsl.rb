module GameDSL
  class GameWrapper
    attr_reader :game

    def initialize
      @game = Magic::Game.new
    end

    def player(name, &block)
      player = Magic::Player.new(name: name)
      game.add_player(player)

      Player.new(game: game, player: player).instance_eval(&block)

      self
    end
  end

  class Player
    attr_reader :game, :player

    def initialize(game:, player:)
      @game = game
      @player = player
    end

    def battlefield(card)
      card = Magic::Cards.const_get(card.gsub(" ", "")).new(game: game)
      game.battlefield << card
    end
  end

  def create_game(&block)
    game_wrapper = GameWrapper.new.instance_eval(&block)
    game_wrapper.game
  end
end
