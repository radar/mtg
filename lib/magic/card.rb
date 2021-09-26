module Magic
  class Card
    attr_reader :name, :zone, :cost
    attr_accessor :controller

    COST = "{0}"

    def initialize(name: NAME, controller: Player.new, zone: CardZone.new, cost: nil)
      @name = name
      @controller = controller
      @zone = zone
      @cost = cost
    end

    def creature?
      false
    end

    def draw!
      move_zone!(:hand)
    end

    def cast!
      move_zone!(:battlefield)
      resolve!
    end

    def resolve!
    end

    private

    def move_zone!(target_zone)
      case target_zone
      when :hand
        zone.draw!
      when :battlefield
        zone.cast!
      else
        raise "invalid zone #{target_zone}"
      end
    end
  end
end
