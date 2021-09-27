module Magic
  class Card
    attr_reader :game, :name, :zone, :cost, :type_line
    attr_accessor :tapped

    attr_accessor :controller

    COST = "{0}"

    def initialize(name: NAME, type_line: "", game: Game.new, controller: Player.new, zone: CardZone.new(self), cost: nil, tapped: false)
      @name = name
      @type_line = type_line
      @game = game
      @controller = controller
      @zone = zone
      @cost = cost
      @tapped = tapped
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

    def resolve!
    end

    def skip_stack?
      false
    end

    def entered_the_battlefield!
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
