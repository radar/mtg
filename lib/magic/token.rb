module Magic
  class Token
    attr_reader :game, :name, :controller
    def initialize(game:, controller:)
      @name = self.class::NAME
      @controller = controller
      @game = game
    end

    def zone=(zone)
      @zone = zone
    end

    def self.resolve(game:, controller:, card:)
      token = new(game: game, controller: controller, card: card.dup)
      token.resolve!(controller)
    end

    def receive_notification(...)
    end

    def static_abilities
      []
    end

    def permanent?
      true
    end

    def token?
      true
    end

    def card
      self
    end
  end
end
