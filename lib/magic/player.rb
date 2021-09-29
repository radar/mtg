module Magic
  class Player
    attr_reader :name, :game, :library, :graveyard, :exile, :mana_pool, :hand, :life

    class UnpayableMana < StandardError; end

    def initialize(
      name: "",
      graveyard: Zones::Graveyard.new(owner: self, cards: []),
      library: [],
      hand: Zones::Hand.new(owner: self, cards: []),
      mana_pool: Hash.new(0),
      floating_mana: Hash.new(0),
      life: 20
    )
      @name = name
      @library = Zones::Library.new(owner: self, cards: library)
      @graveyard = graveyard
      @exile = Zones::Exile.new(owner: self)
      @hand = hand
      @mana_pool = mana_pool
      @floating_mana = floating_mana
      @life = life
    end

    def gain_life(life)
      @life += life

      game.notify!(
        Events::LifeGain.new(
          player: self,
          life: life,
        )
      )
    end

    def take_damage(damage)
      @life -= damage
    end

    def add_mana(mana)
      mana.each do |color, count|
        @mana_pool[color] += count
      end
    end

    def pay_mana(mana)
      if mana.any? { |color, count| mana_pool[color] - count < 0 }
        raise UnpayableMana, "Cannot pay mana #{mana.inspect}, there is only #{mana_pool.inspect} available"
      end

      mana.each do |color, count|
        @mana_pool[color] -= count
      end
    end

    def draw!
      card = library.draw
      card.move_to_hand!(self)
      card.controller = self
      hand.add(card)
    end

    def cast!(card)
      pay_mana(card.cost)
      card.cast!
      @hand.remove(card)
    end

    def tap!(card)
      card.tap!
    end

    def can_cast?(card)
      pool = mana_pool.dup
      card.cost.except(:any).each do |color, count|
        pool[color] -= count
      end

      any_mana_payable = card.cost[:any].nil? || pool.any? { |_, count| count >= card.cost[:any] }
      all_above_zero = pool.all? { |_, count| count >= 0 }

      any_mana_payable && all_above_zero
    end

    def join_game(game)
      @game = game
    end
  end
end
