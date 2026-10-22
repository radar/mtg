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
    # "You have an enduring story" (Storied, The Hobbit): latched by Magic::Storied, lasts for the rest of the game.
    attr_accessor :enduring_story

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

    # The Rooms this player controls, and their unlocked doors (a Room's door is a half-card, so two Rooms of the same
    # name each have their own).
    def rooms = permanents.select(&:room?)
    def unlocked_doors = rooms.flat_map { _1.card.unlocked_doors }

    # Pays a locked door's cost to unlock it (`door:` is `:left`, `:right` or one of the Room's doors).
    def unlock_door(permanent:, door:, **args, &block)
      action = prepare_action(Magic::Actions::UnlockDoor, permanent: permanent, door: door, **args, &block)
      game.take_action(action)
    end

    # Ninjutsu: pays the cost and returns the unblocked +attacker+ to put +card+ (in hand) onto the battlefield attacking.
    def ninjutsu(card:, attacker:, **args, &block)
      action = prepare_action(Magic::Actions::Ninjutsu, card: card, attacker: attacker, **args, &block)
      game.take_action(action)
    end

    # Suspend: pays +card+'s suspend cost to exile it from hand with its time counters.
    def suspend(card:, **args, &block)
      action = prepare_action(Magic::Actions::Suspend, card: card, **args, &block)
      game.take_action(action)
    end

    # Pays a face-down creature card's mana cost to turn it face up.
    def turn_face_up(permanent:, **args, &block)
      action = prepare_action(Magic::Actions::TurnFaceUp, permanent: permanent, **args, &block)
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
      # Activation restrictions are checked before any cost is paid, including those paid in the block (rule 602.5b):
      # exiling the source from the graveyard, say, must not make the ability fail its own "in your graveyard" check.
      action.verify_requirements! if action.respond_to?(:verify_requirements!)
      yield action if block_given?
      action.pay_self_tap if action.has_cost?(Magic::Costs::SelfTap) && auto_tap
      action.pay_self_sacrifice if action.has_cost?(Magic::Costs::SelfSacrifice)
      action.pay_self_exile if action.has_cost?(Magic::Costs::SelfExile)
      action.pay_self_discard if action.has_cost?(Magic::Costs::SelfDiscard)
      action.finalize_costs!(self)
      game.take_action(action)
    end

    def activate_loyalty_ability(ability:, auto_tap: true, **args)
      action = prepare_action(Magic::Actions::ActivateLoyaltyAbility, ability: ability, **args)
      yield action if block_given?
      game.take_action(action)
    end

    # @param cast_class [Class] `Actions::Cast`, or a subclass such as `Actions::Cast::Flashback`
    def prepare_cast(cast_class = Magic::Actions::Cast, card:, **args)
      action = prepare_action(cast_class, card: card, **args)
      yield action if block_given?
      action
    end

    # A Room is cast as one of its doors: `cast(card: room, door: :left)` is `cast_as(:door, card: room, door: :left)`.
    def cast(card:, **args, &block)
      cast_as(args.key?(:door) ? :door : :normal, card:, **args, &block)
    end

    # @param mode [Symbol] How the spell is cast: `:flashback`, `:harmonize`, `:blitz`, `:evoked`, `:adventure`,
    #   `:alternative`, `:door` (a Room) or `:normal` (see `Actions::Cast.for_mode`)
    def cast_as(mode, card:, **args, &block)
      action = prepare_cast(Magic::Actions::Cast.for_mode(mode), card: card, **args, &block)
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
    # A one-shot effect can also stop a player gaining life for the rest of the game (Screaming Nemesis).
    def cant_gain_life!
      @cant_gain_life = true
    end

    def can_gain_life?
      return false if @cant_gain_life

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

    # The total life this player has lost so far this turn (damage included).
    def life_lost_this_turn
      game.current_turn.events.select { _1.is_a?(Events::LifeLoss) && _1.player == self }.sum(&:life)
    end

    # The total life this player's opponents have lost so far this turn.
    def opponents_life_lost_this_turn
      game.opponents(self).sum(&:life_lost_this_turn)
    end

    def take_damage(damage)
      lose_life(damage)
    end

    def lands_played
      game.current_turn.actions.count { |action| action.player == self && action.is_a?(Magic::Actions::PlayLand) }
    end

    def max_lands_per_turn
      1 + permanents.sum(&:additional_lands_per_turn) + (@extra_land_drops&.fetch(game.current_turn.number, 0) || 0)
    end

    # "You may play an additional land this turn." Stored as plain data per turn number so the game can still be Marshal-copied.
    def grant_additional_land_this_turn!
      @extra_land_drops ||= Hash.new(0)
      @extra_land_drops[game.current_turn.number] += 1
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
      return false if hexproof? && controller != self

      !protected_from?(source)
    end

    # "You gain hexproof until end of turn" (Dawn's Truce): lasts through the turn it was granted on.
    def gain_hexproof_until_end_of_turn!
      @hexproof_on_turn = game.current_turn.number
    end

    def hexproof?
      !@hexproof_on_turn.nil? && @hexproof_on_turn == game.current_turn.number
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

      record_mana_spent(mana.values.sum)
    end

    def record_mana_spent(amount)
      return unless game && amount.positive?

      game.notify!(Events::ManaSpent.new(player: self, amount: amount, previous_total: game.current_turn.mana_spent_by_player(self)))
    end
    private :record_mana_spent

    def spend_restricted_mana(color, count, use)
      used = []
      @restricted_mana.reject! do |unit|
        next false unless used.size < count && unit.color == color && unit.restriction.permits?(use)

        used << unit
        true
      end
      # A restriction may react to its mana being spent ("When that mana is spent to cast a creature spell, ...").
      used.each { |unit| unit.restriction.spent_on(use, self) if unit.restriction.respond_to?(:spent_on) }
      used.size
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

    # Rule 705: flip a coin. True if the player wins the flip. Specs stub this for a known result.
    def flip_coin!
      [true, false].sample
    end

    def mill(amount)
      # Mill as many as the library holds (rule 701.17b); an empty library mills nothing.
      cards = [amount, library.count].min.times.map do
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
      return if permanents.any? { _1.card.no_maximum_hand_size? }

      fixed = permanents.filter_map { _1.card.fixed_maximum_hand_size }.min
      base = fixed || STARTING_MAXIMUM_HAND_SIZE
      [base - opponents_maximum_hand_size_reduction, 0].max
    end

    # "Skip your draw step" (a permanent answers `skips_draw_step?`).
    def skips_draw_step?
      permanents.any? { _1.card.skips_draw_step? }
    end

    # "Each opponent's maximum hand size is reduced by N" (Locust Miser): permanents answer
    # `opponents_maximum_hand_size_reduction`.
    def opponents_maximum_hand_size_reduction
      game.opponents(self).flat_map(&:permanents).sum { _1.card.opponents_maximum_hand_size_reduction }
    end

    # Rule 514.1: in the cleanup step the active player discards down to their maximum hand size.
    def discard_down_to_maximum_hand_size!
      return unless (maximum = maximum_hand_size)

      excess = [hand.count - maximum, 0].max
      game.add_choice(Choice::Discard.new(player: self, amount: excess)) if excess.positive?
    end

    # Vivid: the number of colors among permanents this player controls.
    def colors_among_permanents
      permanents.flat_map { |permanent| permanent.colors.to_a }.uniq.count
    end

    def lands
      permanents.lands
    end

    # What "an opponent controls/has more <stat> than you" compares (Beza, the Bounding Spring).
    COMPARABLE_STATS = {
      lands: ->(player) { player.lands.count },
      creatures: ->(player) { player.creatures.count },
      life: ->(player) { player.life },
      hand: ->(player) { player.hand.count },
      graveyard: ->(player) { player.graveyard.count },
    }.freeze

    # "If an opponent controls more lands than you" is `behind_an_opponent_in?(:lands)`; `stat` is a key of
    # COMPARABLE_STATS.
    def behind_an_opponent_in?(stat)
      measure = COMPARABLE_STATS.fetch(stat) { raise ArgumentError, "Unknown stat #{stat.inspect}, expected one of #{COMPARABLE_STATS.keys.join(', ')}" }
      game.opponents(self).any? { measure.call(_1) > measure.call(self) }
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

    def foods
      permanents.select { _1.type?("Food") }
    end

    # Forage (Bloomburrow): exile three cards from your graveyard or sacrifice a Food.
    def can_forage?
      graveyard.count >= 3 || foods.any?
    end

    # `payment`: an Array of three cards in your graveyard (exiled), or a Food you control (sacrificed).
    def forage!(payment)
      if payment.is_a?(Magic::Permanent)
        raise "#{payment.name} isn't a Food #{inspect} controls" unless foods.include?(payment)

        payment.sacrifice!
      else
        cards = Array(payment)
        raise "Forage needs three cards from the graveyard" unless cards.size == 3 && cards.all? { graveyard.cards.include?(_1) }

        cards.each(&:exile!)
      end
      game.notify!(Events::Forage.new(player: self))
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

    # How many energy counters ({E}) the player has.
    def energy
      counters.of_type(Counters::Energy).count
    end

    # Pays +amount+ {E}; raises unless the player has that many.
    def pay_energy!(amount)
      raise "#{name} can't pay #{amount} {E}: only has #{energy}" if energy < amount

      amount.times { counters.remove_first(Counters::Energy) }
      game.notify!(Events::EnergyPaid.new(player: self, amount: amount)) if amount.positive?
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
