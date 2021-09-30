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

    def convert_mana!(source_mana, target_mana)
      pay_mana(source_mana)
      add_mana(target_mana)
    end

    def pay_mana(mana)
      if mana.any? { |color, count| mana_pool[color] - count < 0 }
        raise UnpayableMana, "Cannot pay mana #{mana.inspect}, there is only #{mana_pool.inspect} available"
      end

      mana.each do |color, count|
        @mana_pool[color] -= count
      end
    end

    def can_cast?(card)
      action = CastAction.new(
        player: self,
        game: game,
        card: card
      )
      action.can_cast?
    end

    def draw!
      card = library.draw
      card.move_to_hand!(self)
      card.controller = self
      hand.add(card)
    end

    def cast!(card, mana = {})
      pay_mana(mana) if mana.any?
      card.cast!
      @hand.remove(card)
    end

    def tap!(card)
      card.tap!
    end

    def join_game(game)
      @game = game
    end
  end
end
