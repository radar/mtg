module Magic
  class Card
    attr_reader :game, :name, :zone, :cost, :type_line, :countered, :keywords
    attr_accessor :tapped

    attr_accessor :controller

    COST = "{0}"
    KEYWORDS = []

    def initialize(game: Game.new, controller: Player.new, zone: CardZone.new(self), cost: self.class::COST, tapped: false, keywords: [])
      @countered = false
      @name = self.class::NAME
      @type_line = self.class::TYPE_LINE
      @game = game
      @controller = controller
      @zone = zone
      @cost = self.class::COST
      @tapped = tapped
      @keywords = self.class::KEYWORDS
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
      move_zone!(:hand)
    end

    def cast!
      if skip_stack?
        add_to_battlefield!
      else
        game.stack.add(self)
      end
    end

    def add_to_battlefield!
      game.battlefield << self
      move_zone!(:battlefield)
      game.notify!(
        Events::EnterTheBattlefield.new(self)
      )
    end

    def destroy!
      move_zone!(:graveyard)
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
      add_to_battlefield!
    end

    def counter!
      @countered = true
      move_zone!(:graveyard)
    end

    def resolution_effects
      []
    end

    def skip_stack?
      false
    end

    def entered_the_battlefield!
    end

    def notify(event)
    end

    def take_damage(damage_dealt)
      @damage += damage_dealt
    end

    private

    def move_zone!(target_zone)
      case target_zone
      when :hand
        zone.draw!
      when :battlefield
        zone.battlefield!
      when :graveyard
        zone.graveyard!
      else
        raise "invalid zone #{target_zone}"
      end
    end
  end
end
