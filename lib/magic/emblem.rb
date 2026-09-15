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

    def permits_casting_from_graveyard?(card) = false
    def exiles_after_graveyard_cast?(card) = false
  end
end
