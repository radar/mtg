module Magic
  class Player
    include Targetable
    extend Forwardable

    attr_reader :name, :game, :lost, :library, :graveyard, :exile, :mana_pool, :hand, :life, :starting_life, :counters

    def_delegators :@game, :logger

    class UnpayableMana < StandardError; end

    def initialize(
      name: "",
      graveyard: Zones::Graveyard.new(owner: self, items: []),
      library: [],
      hand: Zones::Hand.new(owner: self, items: []),
      mana_pool: Hash.new(0),
      floating_mana: Hash.new(0),
      life: 20
    )
      @name = name
      @lost = false
      @library = Zones::Library.new(owner: self, items: library)
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

    def prepare_action(action, **args, &block)
      action = action.new(player: self, game: game, **args)
      yield action if block_given?
      action
    end

    def take_action(action, **args)
      if action.is_a?(Class)
        action = prepare_action(action, **args)
      end

      game.take_action(action)
    end

    def play_land(land:, **args)
      action = prepare_action(Magic::Actions::PlayLand, card: land, **args)
      game.take_action(action)
    end

    def prepare_activate_ability(ability:, **args, &block)
      prepare_action(Magic::Actions::ActivateAbility, ability: ability, **args)
    end

    def activate_ability(ability:, auto_tap: true, **args, &block)
      if ability.is_a?(Magic::ManaAbility)
        action = prepare_action(Magic::Actions::ActivateManaAbility, ability: ability, **args)
      else
        action = prepare_activate_ability(ability: ability, **args, &block)
      end
      yield action if block_given?
      action.pay_self_tap if action.has_cost?(Magic::Costs::SelfTap) && auto_tap
      action.pay_self_sacrifice if action.has_cost?(Magic::Costs::SelfSacrifice)
      action.finalize_costs!(self)
      game.take_action(action)
    end

    def activate_loyalty_ability(ability:, auto_tap: true, **args)
      action = prepare_action(Magic::Actions::ActivateLoyaltyAbility, ability: ability, **args)
      yield action if block_given?
      game.take_action(action)
    end

    def prepare_cast(card:, **args)
      action = prepare_action(Magic::Actions::Cast, card: card, **args)
      yield action if block_given?
      action
    end

    def cast(card:, **args, &block)
      action = prepare_cast(card: card, **args, &block)
      game.take_action(action)
      action
    end

    def prepare_declare_attacker(attacker:, target: nil, **args)
      prepare_action(Magic::Actions::DeclareAttacker, attacker: attacker, target: target, **args)
    end

    def declare_attacker(attacker:, target: nil, **args)
      action = prepare_action(Magic::Actions::DeclareAttacker, attacker: attacker, target: target, **args)
      game.take_action(action)
      action
    end

    def skip_choice(choice)
      game.skip_choice!
    end

    def lost?
      @lost
    end

    def lose!
      game.notify!(
        Events::PlayerLost.new(
          player: self,
        )
      )

      @lost = true
    end

    def gain_life(gain)
      game.notify!(
        Events::LifeGain.new(
          player: self,
          life: gain,
        )
      )
    end

    def lose_life(loss)
      @life -= loss

      game.notify!(
        Events::LifeLoss.new(
          player: self,
          life: loss,
        )
      )
    end

    def take_damage(damage)
      lose_life(damage)
    end

    def lands_played
      game.current_turn.actions.count { |action| action.player == self && action.is_a?(Magic::Actions::PlayLand) }
    end

    def max_lands_per_turn
      1 + permanents.sum(&:additional_lands_per_turn)
    end

    def can_play_lands?
      lands_played < max_lands_per_turn
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
      logger.debug "Paying mana: #{mana.inspect}" if game
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

    def shuffle!
      library.shuffle!
    end

    def mill(amount)
      cards = amount.times.map do
        card = library.mill
        card.move_to_graveyard!
        game.notify!(
          Events::CardMilled.new(
            player: self,
            card: card,
          )
        )
        card
      end

      CardList.new(cards)
    end

    def scry(amount:, top:, bottom:)
      cards = library.shift(amount)
      library.unshift(*top)
      library.push(*bottom)
      game.notify!(
        Events::Scry.new(
          player: self,
          top: top.count,
          bottom: bottom.count,
        )
      )
    end

    def surveil(amount:, graveyard:, top:)
      cards = library.shift(amount)
      library.unshift(*top)
      graveyard.compact.each { |card| card.move_to_graveyard!(self) }
      game.notify!(
        Events::Surveil.new(
          player: self,
          graveyard: graveyard.count,
          top: top.count,
        )
      )
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

    def lands
      permanents.lands
    end

    def creatures
      permanents.creatures
    end

    def planeswalkers
      permanents.planeswalkers
    end

    def event_targets_self?(event)
      (event.respond_to?(:player) && event.player == self) ||
        (event.respond_to?(:target) && event.target == self)
    end

    def receive_event(event)
      return unless event_targets_self?(event)
      case event
      when Events::LifeGain
        @life += event.life
      when Events::PlayerLoses
        lose!
      when Events::DamageDealt
        trigger_effect(:lose_life, life: event.damage, source: event.source)
      end
    end

    def trigger_effect(effect_name, **args)
      case effect_name
      when :add_counter
        game.add_effect(Effects::AddCounterToPlayer.new(source: args[:source], player: args[:target], **args))
      when :lose_life
        game.add_effect(Effects::LoseLife.new(target: self, **args))
      end
    end

    def protected_from?(card)
      permanents.flat_map { |card| card.protections.player }.any? { |protection| protection.protected_from?(card) }
    end

    def add_counter(counter_type:, amount: 1)
      @counters = Counters::Collection.new(@counters + [counter_type.new] * amount)
    end

    def devotion(color)
      permanents.sum { |permanent| permanent.devotion(color) }
    end
  end
end
