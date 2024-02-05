module Magic
  class Choice
    attr_reader :source
    def initialize(source:)
      @source = source
    end

    def controller = source.controller
    def game = controller.game
    def battlefield = game.battlefield
    def creatures = battlefield.creatures

    def to_s = inspect
  end
end
