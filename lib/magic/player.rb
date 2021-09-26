module Magic
  class Player
    attr_reader :game, :library, :mana_pool, :hand

    def initialize(game: Game.new, library: Library.new([]), hand: [], mana_pool: Hash.new(0))
      @game = game
      @library = library
      @hand = hand
      @mana_pool = mana_pool
    end

    def add_mana(color, count = 1)
      @mana_pool[color] += count
    end

    def draw!
      card = @library.draw
      card.draw!
      card.controller = self
      hand << card
    end

    def play!(card)
      game.battlefield << card
      @hand -= [card]
    end

    def can_cast?(card)
      available_mana = mana_pool.dup
      card.cost.except(:any).each do |color, count|
        available_mana[color] -= count
      end

      any_mana_payable = card.cost[:any].nil? || available_mana.any? { |_, count| count >= card.cost[:any] }
      all_above_zero = available_mana.all? { |_, count| count >= 0 }

      any_mana_payable && all_above_zero
    end
  end
end
