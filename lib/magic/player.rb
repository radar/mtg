module Magic
  class Player
    attr_reader :name, :game, :lost, :library, :graveyard, :exile, :mana_pool, :hand, :life

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
      @lost = false
      @library = Zones::Library.new(owner: self, cards: library)
      @graveyard = graveyard
      @exile = Zones::Exile.new(owner: self)
      @hand = hand
      @mana_pool = mana_pool
      @floating_mana = floating_mana
      @life = life
    end

    def inspect
      "#<Player name:#{name.inspect}>"
    end

    def lost?
      @lost
    end

    def lose!
      @lost = true

      game.notify!(
        Events::PlayerLoses,
        player: self,
      )
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

    def lands_played
      game.current_turn.actions.count { |action| action.player == self && action.is_a?(Magic::Actions::PlayLand) }
    end

    def max_lands_per_turn
      1
    end

    def can_play_lands?
      lands_played >= max_lands_per_turn
    end

    def can_be_targeted_by?(source)
      true
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
      game.notify!(
        Events::CardDraw.new(
          player: self,
        )
      )
      card.move_to_hand!(self)
    end

    def prepare_to_cast(card)
      cast_action(card)
    end

    def activate_ability(ability)
      ActivateAbilityAction.new(
        game: game,
        player: self,
        ability: ability
      )
    end

    def tap!(card)
      card.tap!
    end

    def join_game(game)
      @game = game
    end

    def permanents
      game.battlefield.controlled_by(self).permanents
    end

    def creatures
      permanents.creatures
    end

    def receive_event(event)
      case event
      when Events::DamageDealt
        return unless event.target == self

        take_damage(event.damage)
      end
    end

    def protected_from?(card)
      permanents.flat_map { |card| card.protections.player }.any? { |protection| protection.protected_from?(card) }
    end

    private

    def cast_action(card)
      CastAction.new(
        player: self,
        game: game,
        card: card,
      )
    end
  end
end
