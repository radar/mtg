module Magic
  class Player
    attr_reader :name, :game, :library, :graveyard, :exile, :mana_pool, :hand, :life, :lands_played

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
      @lands_played = 0
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

      game.notify!(
        Events::LifeLoss.new(
          player: self,
          life: damage,
        )
      )
    end

    def played_a_land!
      @lands_played += 1
    end

    def reset_lands_played
      @lands_played = 0
    end

    def max_lands_per_turn
      1
    end

    def can_play_lands?
      lands_played >= max_lands_per_turn
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
      puts "Paying mana: #{mana.inspect}"
      if mana.any? { |color, count| mana_pool[color] - count < 0 }
        raise UnpayableMana, "Cannot pay mana #{mana.inspect}, there is only #{mana_pool.inspect} available"
      end

      mana.each do |color, count|
        @mana_pool[color] -= count
      end
    end

    def can_cast?(card)
      cast_action(card).can_cast?
    end

    def draw!
      card = library.draw
      card.move_to_hand!(self)
      card.controller = self
    end

    def prepare_to_cast!(card)
      cast_action(card)
    end

    def pay_and_cast!(cost, card)
      action = cast_action(card)
      action.pay(cost)
      action.perform!
    end

    def pay_and_activate_ability!(cost, ability)
      action = activate_ability_action(ability)
      action.pay(cost)
      action.activate!
    end

    def cast!(card)
      action = cast_action(card)
      action.perform!
    end

    def tap!(card)
      card.tap!
    end

    def join_game(game)
      @game = game
    end

    private

    def cast_action(card)
      CastAction.new(
        player: self,
        game: game,
        card: card
      )
    end

    def activate_ability_action(ability)
      ActivateAbilityAction.new(
        player: self,
        ability: ability
      )
    end
  end
end
