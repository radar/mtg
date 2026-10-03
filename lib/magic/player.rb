module Magic
  class Player
    include Targetable
    extend Forwardable

    attr_reader :name, :game, :lost, :library, :graveyard, :exile, :mana_pool, :restricted_mana, :hand, :life, :starting_life, :counters, :commander, :attachments
    attr_accessor :ring_bearer, :spell_cast_limit, :spell_cast_limit_turn
    # Roadmap C2: the Magic::Agent driving this player's decisions for Game#run!. Unset by
    # default -- nothing outside GameRunner reads it, so every other caller keeps driving
    # the player directly.
    attr_accessor :agent

    def_delegators :@game, :logger

    class UnpayableMana < StandardError; end

    def initialize(
      name: "",
      graveyard: Zones::Graveyard.new(owner: self, items: []),
      library: [],
      hand: Zones::Hand.new(owner: self, items: []),
      exile: Zones::Exile.new(owner: self, items: []),
      mana_pool: Hash.new(0),
      floating_mana: Hash.new(0),
      life: 20
    )
      @name = name
      @lost = false
      @library = Zones::Library.new(owner: self, items: library)
      @graveyard = graveyard
      @hand = hand
      @exile = exile
      @mana_pool = mana_pool
      @floating_mana = floating_mana
      @restricted_mana = []
      @starting_life = life
      @life = life
      @counters = Counters::Collection.new([])
      @attachments = []
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

    def play_land(land:, **args, &block)
      action = prepare_action(Magic::Actions::PlayLand, card: land, **args, &block)
      game.take_action(action)
    end

    def cycle(card:, **args, &block)
      action = prepare_action(Magic::Actions::Cycle, card: card, **args, &block)
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
      action.verify_requirements! if action.respond_to?(:verify_requirements!)
      action.pay_self_tap if action.has_cost?(Magic::Costs::SelfTap) && auto_tap
      action.pay_self_sacrifice if action.has_cost?(Magic::Costs::SelfSacrifice)
      action.pay_self_exile if action.has_cost?(Magic::Costs::SelfExile)
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

    def limit_spells_this_turn!(count)
      @spell_cast_limit = count
      @spell_cast_limit_turn = game.current_turn.number
    end

    def spell_cast_limited?
      spell_cast_limit && spell_cast_limit_turn == game.current_turn.number
    end

    def spell_cast_limit_reached?
      spell_cast_limited? && spell_cast_limit <= 0
    end

    def consume_spell_cast!
      @spell_cast_limit -= 1 if spell_cast_limited?
    end

    def prepare_declare_attacker(attacker:, target: nil, **args)
      prepare_action(Magic::Actions::DeclareAttacker, attacker: attacker, target: target, **args)
    end

    def declare_attacker(attacker:, target: nil, **args)
      action = prepare_action(Magic::Actions::DeclareAttacker, attacker: attacker, target: target, **args)
      game.take_action(action)
      action
    end

    # Legality-checked counterpart to `current_turn.declare_blocker(blocker, attacker:)`
    # (the raw `CombatPhase` delegate): goes through `Turn#take_action`, so an illegal
    # block raises `Magic::IllegalAction` rather than `CombatPhase::IllegalBlock`.
    def declare_blocker(blocker:, attacker:, **args)
      action = prepare_action(Magic::Actions::DeclareBlocker, blocker: blocker, attacker: attacker, **args)
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
      game.unsubscribe(self)
    end

    # A static ability of a permanent can define `prevents_life_gain?(player)` (Mornsong Aria).
    def can_gain_life?
      game.battlefield.static_abilities.none? { |ability| ability.respond_to?(:prevents_life_gain?) && ability.prevents_life_gain?(self) }
    end

    # Likewise `prevents_drawing?(player)`.
    def can_draw?
      game.battlefield.static_abilities.none? { |ability| ability.respond_to?(:prevents_drawing?) && ability.prevents_drawing?(self) }
    end

    def gain_life(gain)
      return unless can_gain_life?

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

    # "Until your next turn, prevent all damage that would be dealt to you."
    def prevent_all_damage_until_next_turn!
      @damage_prevented_since_turn = game.current_turn.number
    end

    def prevents_damage?
      return false unless @damage_prevented_since_turn

      game.turns.none? { |turn| turn.active_player == self && turn.number > @damage_prevented_since_turn && turn.number <= game.current_turn.number }
    end

    def can_be_targeted_by?(source, controller: source&.controller)
      return true if source.nil?

      !protected_from?(source)
    end

    # With a `restriction` ("spend this mana only to ..."), each unit is kept in
    # `restricted_mana` instead of the plain pool, so only a matching spell/ability can use it.
    def add_mana(mana = {}, restriction: nil, **colors)
      mana.merge(colors).each do |color, count|
        if restriction
          count.times { @restricted_mana << RestrictedMana.new(color: color, restriction: restriction) }
        else
          @mana_pool[color] += count
        end
      end
    end

    RestrictedMana = Data.define(:color, :restriction)

    # The restricted mana `use` may spend, as { color => count }.
    def restricted_mana_for(use)
      @restricted_mana.select { |unit| unit.restriction.permits?(use) }.map(&:color).tally
    end

    # Plain pool plus the restricted mana `use` may spend.
    def spendable_mana_for(use)
      restricted_mana_for(use).each_with_object(Hash.new(0).merge(mana_pool)) do |(color, count), pool|
        pool[color] += count
      end
    end

    def convert_mana!(source_mana, target_mana)
      pay_mana(source_mana)
      add_mana(target_mana)
    end

    # `for_use`: what the mana is spent on. Restricted mana it permits is spent first (it
    # can't pay for anything else), then the plain pool.
    def pay_mana(mana = {}, for_use: nil, **colors)
      mana = mana.merge(colors)
      logger.debug "Paying mana: #{mana.inspect}" if game
      available = for_use ? spendable_mana_for(for_use) : mana_pool
      if mana.any? { |color, count| available[color] - count < 0 }
        raise UnpayableMana, "Cannot pay mana #{mana.inspect}, there is only #{available.inspect} available"
      end

      mana.each do |color, count|
        count -= spend_restricted_mana(color, count, for_use) if for_use
        @mana_pool[color] -= count
      end
    end

    def spend_restricted_mana(color, count, use)
      spent = 0
      @restricted_mana.reject! do |unit|
        next false unless spent < count && unit.color == color && unit.restriction.permits?(use)

        spent += 1
        true
      end
      spent
    end
    private :spend_restricted_mana

    # Rule 704.5b: drawing from an empty library doesn't lose immediately;
    # the player loses the next time state-based actions are checked.
    def drew_from_empty_library?
      @drew_from_empty_library
    end

    def draw!
      return unless can_draw?

      if library.none?
        @drew_from_empty_library = true
        return
      end

      card = library.draw
      game.notify!(
        Events::CardDraw.new(
          player: self,
          card: card,
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
      library.shift(amount)
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

    def reveal(*cards)
      cards = cards.flat_map { |c| c.is_a?(Zone) ? c.cards : c }
      cards.each { |card| card.reveal!(notify: false) }
      game&.notify!(Events::CardsRevealed.new(player: self, cards: cards))
      cards
    end

    def revealed_cards
      hand.select(&:revealed?)
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

    STARTING_MAXIMUM_HAND_SIZE = 7

    # Rule 402.2: seven, unless a permanent says "You have no maximum hand size" (nil then).
    def maximum_hand_size
      return if permanents.any? { _1.card.respond_to?(:no_maximum_hand_size?) && _1.card.no_maximum_hand_size? }

      STARTING_MAXIMUM_HAND_SIZE
    end

    # Rule 514.1: in the cleanup step the active player discards down to their maximum hand size.
    def discard_down_to_maximum_hand_size!
      return unless (maximum = maximum_hand_size)

      [hand.count - maximum, 0].max.times { game.add_choice(Choice::Discard.new(player: self)) }
    end

    # Vivid: the number of colors among permanents this player controls.
    def colors_among_permanents
      permanents.flat_map { |permanent| permanent.colors.to_a }.uniq.count
    end

    def lands
      permanents.lands
    end

    def artifacts
      permanents.artifacts
    end

    def enchantments
      permanents.enchantments
    end

    def equipment
      permanents.equipment
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

    def choose_replacement_effect(effect:, replacement_effects:, replacement_context: nil)
      replacement_effects.first
    end

    def protected_from?(card)
      permanents.flat_map { |card| card.protections.player }.any? { |protection| protection.protected_from?(card) }
    end

    def add_counter(counter_type, amount: 1)
      resolved = Counters[counter_type]
      @counters = Counters::Collection.new(@counters + Array.new(amount) { resolved.new })
    end

    def devotion(color)
      permanents.sum { |permanent| permanent.devotion(color) }
    end

    def add_commander(commander)
      @commander = commander
    end

    def monarch?
      game.monarch == self
    end

    def become_monarch!
      game.make_monarch!(self)
    end
  end
end
