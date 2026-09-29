module Magic
  class Protection
    attr_reader :condition, :until_eot, :until_turn_of

    # `until_turn_of`: a player -- lasts until that player's next turn begins ("until your next turn").
    def initialize(condition:, until_eot: false, protects_player: false, until_turn_of: nil)
      @condition = condition
      @until_eot = until_eot
      @protects_player = protects_player
      @until_turn_of = until_turn_of
    end

    def protects_player?
      @protects_player
    end

    def until_eot?
      @until_eot
    end

    def self.from_color(color, until_eot: false, until_turn_of: nil)
      new(condition: -> (card) { card.colors.include?(color) }, until_eot: until_eot, until_turn_of: until_turn_of)
    end

    def protected_from?(card)
      condition.call(card)
    end
  end
end
