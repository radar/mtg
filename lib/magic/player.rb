module Magic
  class Player
    attr_reader :name, :game, :lost, :library, :graveyard, :exile, :mana_pool, :hand, :life, :starting_life, :counters

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
      @hand = hand
      @mana_pool = mana_pool
      @floating_mana = floating_mana
      @starting_life = life
      @life = life
      @counters = Counters::Collection.new([])
    end

    def inspect
      "#<Player name:#{name.inspect}>"
    end
    alias_method :to_s, :inspect

    def lost?
      @lost
    end

    def lose!
      @lost = true
    end

    def gain_life(life)
      game.notify!(
        Events::LifeGain.new(
          player: self,
          life: life,
        )
      )
    end

    def take_damage(source:, damage:)
      game.notify!(
        Events::DamageDealt,
        source: source,
        damage: damage,
        target: self,
      )

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

    def draw!
      lose! and return if library.none?

      card = library.draw
      game.notify!(
        Events::CardDraw.new(
          player: self,
        )
      )
      card.move_to_hand!(self)
    end

    def tap!(card)
      card.tap!
    end

    def join_game(game)
      @game = game
    end

    def permanents
      game.battlefield.permanents.controlled_by(self)
    end

    def creatures
      permanents.creatures
    end

    def planeswalkers
      permanents.planeswalkers
    end

    def receive_event(event)
      return if !event.respond_to?(:player) || event.player != self
      case event
      when Events::LifeLoss
        @life -= event.life
      when Events::LifeGain
        @life += event.life
      when Events::PlayerLoses
        lose!
      end
    end

    def protected_from?(card)
      permanents.flat_map { |card| card.protections.player }.any? { |protection| protection.protected_from?(card) }
    end

    def add_counter(counter_type, amount: 1)
      @counters = Counters::Collection.new(@counters + [counter_type.new] * amount)
      counter_added = Events::CounterAdded.new(
        player: self,
        counter_type: counter_type,
        amount: amount
      )

      game.notify!(counter_added)
    end
  end
end
