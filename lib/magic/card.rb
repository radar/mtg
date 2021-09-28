module Magic
  class Card
    attr_reader :game, :name, :cost, :type_line, :countered, :keywords
    attr_accessor :tapped

    attr_accessor :controller, :zone

    COST = "{0}"
    KEYWORDS = []

    def initialize(game: Game.new, controller: Player.new, tapped: false, keywords: [])
      @countered = false
      @name = self.class::NAME
      @type_line = self.class::TYPE_LINE
      @game = game
      @controller = controller
      @zone = controller.library
      @cost = self.class::COST
      @tapped = tapped
      @keywords = self.class::KEYWORDS
    end

    def inspect
      "#<Card name:#{name} controller:#{controller.name}>"
    end

    def creature?
      type_line.include?("Creature")
    end

    def artifact?
      type_line.include?("Artifact")
    end

    def enchantment?
      type_line.include?("Enchantment")
    end

    def flying?
      keywords.include?(Keywords::FLYING)
    end

    def draw!
      move_zone!(controller.hand)
    end

    def cast!
      if skip_stack?
        move_zone!(game.battlefield)
      else
        game.stack.add(self)
      end
    end

    def tap!
      @tapped = true
    end

    def untap!
      @tapped = false
    end

    def tapped?
      @tapped
    end

    def untapped?
      !tapped?
    end

    def countered?
      countered
    end

    def controller?(other_controller)
      controller == other_controller
    end

    def resolve!
      move_zone!(game.battlefield)
    end

    def counter!
      @countered = true
      move_zone!(controller.graveyard)
    end

    def destroy!
      move_zone!(controller.graveyard)
    end

    def resolution_effects
      []
    end

    def skip_stack?
      false
    end

    def entered_the_battlefield!
    end

    def notify!(event)
      game.notify!(event)
    end

    def receive_notification(notification)
    end

    def take_damage(damage_dealt)
      @damage += damage_dealt
    end

    private

    def move_zone!(new_zone)
      zone.remove(self)
      new_zone.add(self)

      game.notify!(
        Events::ZoneChange.new(
          self,
          from: zone,
          to: new_zone
        )
      )
    end
  end
end
