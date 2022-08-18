module Magic
  class LoyaltyAbility
    attr_reader :planeswalker, :game

    def initialize(planeswalker:)
      @planeswalker = planeswalker
      @game = planeswalker.game
    end
  end
end
