module Magic
  class Choice
    attr_reader :source
    def initialize(source:)
      @source = source
    end

    def player = source.controller
    def game = player.game
    def battlefield = game.battlefield

    def to_s = inspect
  end
end
