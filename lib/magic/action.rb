module Magic
  class Action
    attr_reader :player

    def initialize(player:)
      @player = player
    end
  end
end
