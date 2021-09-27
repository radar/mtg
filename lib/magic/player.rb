module Magic
  class Player
    attr_reader :game, :library, :mana_pool, :floating_mana, :hand, :life
    class UnfloatableMana < StandardError; end

    def initialize(
      game: Game.new,
      library: Library.new([]),
      hand: [],
      mana_pool: Hash.new(0),
      floating_mana: Hash.new(0),
      life: 20
    )
      @game = game
      @library = library
      @hand = hand
      @mana_pool = mana_pool
      @floating_mana = floating_mana
      @life = life
    end

    def gain_life(life)
      @life += life
    end

    def add_mana(mana)
      mana.each do |color, count|
        @mana_pool[color] += count
      end
    end

    def float_mana(mana)
      if mana.any? { |color, count | mana_pool[color] - count < 0 }
        raise UnfloatableMana, "Cannot float mana #{mana.inspect}, there is only #{mana_pool.inspect} available"
      end

      mana.each do |color, count|
        @mana_pool[color] -= count
        @floating_mana[color] += count
      end
    end

    def draw!
      card = @library.draw
      card.draw!
      card.controller = self
      hand << card
    end

    def cast!(card)
      card.cast!
      @hand -= [card]
    end

    def can_cast?(card)
      card.cost.except(:any).each do |color, count|
        floating_mana[color] -= count
      end

      any_mana_payable = card.cost[:any].nil? || floating_mana.any? { |_, count| count >= card.cost[:any] }
      all_above_zero = floating_mana.all? { |_, count| count >= 0 }

      any_mana_payable && all_above_zero
    end
  end
end
