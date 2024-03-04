module Magic
  class Emblem
    include Cards::Shared::Events

    attr_reader :game, :owner

    def initialize(game:, owner:)
      @game = game
      @owner = owner
    end

    def receive_event(event)
    end
  end
end
