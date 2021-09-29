module Magic
  class Card
    attr_reader :game, :name, :cost, :type_line, :countered, :keywords
    attr_accessor :tapped

    attr_accessor :controller, :zone

    COST = {}
    KEYWORDS = []

    def initialize(game: Game.new, controller: Player.new, tapped: false, keywords: [], card_event: CardState.new(self))
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

    def type?(type)
      type_line.split(" ").include?(type)
    end

    def basic_land?
      type?("Basic") && type?("Land")
    end

    def creature?
      type?("Creature")
    end

    def artifact?
      type?("Artifact")
    end

    def enchantment?
      type?("Enchantment")
    end

    def flying?
      keywords.include?(Keywords::FLYING)
    end

    def move_to_hand!(target_controller)
      move_zone!(target_controller.hand)
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

    def exile!
      move_zone!(controller.exile)
    end

    def resolution_effects
      []
    end

    def skip_stack?
      false
    end

    def notify!(event)
      game.notify!(event)
    end

    def receive_notification(event)
      case event
      when Events::ZoneChange
        died! if event.card == self && event.death?
        entered_the_battlefield! if event.card == self && event.to.battlefield?
      end
    end

    def died!
    end

    def entered_the_battlefield!
    end

    private

    def move_zone!(new_zone)
      old_zone = zone
      old_zone.remove(self)
      new_zone.add(self)

      game.notify!(
        Events::ZoneChange.new(
          self,
          from: old_zone,
          to: new_zone
        )
      )
    end
  end
end
