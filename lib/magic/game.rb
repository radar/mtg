module Magic
  class Game
    extend Forwardable

    attr_reader :logger, :battlefield, :exile, :turns, :stack, :players, :emblems, :current_turn, :event_listeners, :monarch,
                :play_permissions

    class EmblemList
      include Enumerable

      def initialize(game)
        @game = game
        @items = []
      end

      def <<(emblem)
        @items << emblem
        @game.subscribe(emblem)
        self
      end

      def each(&block)
        @items.each(&block)
      end
    end

    def_delegators :@battlefield, :creatures
    def_delegators :@stack, :choices, :add_choice, :skip_choice!, :resolve_choice!, :effects

    def_delegators :@current_turn, :take_action, :take_actions, :can_cast_sorcery?

    def self.start!(players: [])
      new.tap do |game|
        players.each { |player| game.add_player(player) }
        game.start!
        game.next_turn
      end
    end

    def initialize(
      battlefield: Zones::Battlefield.new(owner: self),
      exile: Zones::Exile.new(owner: self),
      effects: [],
      players: [],
      stack: nil,
      logger: nil,
      queue_triggers: true,
      enforce_priority: false
    )
      @logger = Logger.new(STDOUT)
      @battlefield = battlefield
      @exile = exile
      @stack = Stack.new(logger: @logger, game: self)
      @effects = effects
      @logger.level = ENV['LOG_LEVEL'] || "INFO"
      @player_count = 0
      @players = players
      @emblems = EmblemList.new(self)
      @play_permissions = PlayPermissions.new(self)
      @turns = []
      @event_listeners = []
      @monarch = nil
      @queue_triggers = queue_triggers
      @pending_triggers = []
      @enforce_priority = enforce_priority
      @priority_player = nil
      @priority_passes = 0
      subscribe(self)
    end

    attr_reader :priority_player, :priority_passes

    # When true, Turn#take_action rejects actions from a player who doesn't hold priority.
    # Off by default so specs that drive several players' actions directly keep working.
    def enforce_priority?
      @enforce_priority
    end

    # Rule 117.3: +player+ receives priority and the pass count restarts.
    def grant_priority!(player)
      @priority_player = player
      @priority_passes = 0
    end

    # Steps with no priority (untap, cleanup).
    def revoke_priority!
      @priority_player = nil
      @priority_passes = 0
    end

    def priority_reason(action)
      return unless enforce_priority? && action.uses_priority?
      return if priority_player == action.player

      "#{action.player.inspect} does not have priority"
    end

    # Rule 117.3c: a player who takes an action that uses priority keeps priority afterwards,
    # and the players who had already passed must pass again.
    def priority_action_taken!(action)
      grant_priority!(action.player) if action.uses_priority? && priority_player
    end

    # Rule 117.3d: the priority player passes. When every remaining player has passed in
    # succession, the top item of the stack resolves (and the active player gets priority
    # again), or, with an empty stack, the step ends. Returns :passed, :resolved, :step_ended
    # or :choice_pending (a choice must be resolved before priority can move on).
    def pass_priority!
      raise "No player has priority" unless priority_player
      return :choice_pending if stack.pending_choices?

      @priority_passes += 1
      if @priority_passes < remaining_players.size
        @priority_player = player_after(priority_player)
        return :passed
      end

      if stack.empty?
        current_turn.advance_step!
        :step_ended
      else
        stack.resolve_top!
        receive_priority!(current_turn.active_player)
        :resolved
      end
    end

    # Rule 117.5: SBAs are checked and pending triggers go on the stack before a player
    # receives priority; if anything went on the stack the active player receives it.
    def receive_priority!(player)
      stack_size = stack.count
      check_state_based_actions!
      grant_priority!(stack.count > stack_size ? current_turn.active_player : player)
    end

    def queue_triggers?
      @queue_triggers
    end

    def pending_triggers
      @pending_triggers
    end

    def queue_trigger!(ability)
      @pending_triggers << ability
    end

    def add_players(*players)
      players.each(&method(:add_player))
    end

    def add_player(player)
      @player_count += 1
      @players << player
      player.join_game(self)
      subscribe(player)
    end

    def add_emblem(emblem)
      @emblems << emblem  # EmblemList handles subscription
    end

    def subscribe(listener)
      @event_listeners << listener
    end

    def unsubscribe(listener)
      @event_listeners.delete(listener)
    end

    def start!
      @current_turn = add_turn(number: 1, active_player: players.first)
      players.each do |player|
        7.times { player.draw! }
      end
    end

    def notify!(*events)
      current_turn.notify!(*events)
    end

    def take_additional_turn(player: current_turn.active_player)
      add_turn(number: @turns.size + 1, active_player: player)
    end

    def add_turn(number: @turns.size + 1, active_player: player)
      turn = Turn.new(number: number, game: self, active_player: active_player)
      @turns << turn
      turn
    end

    def next_turn
      next_turn = turns.find { |turn| turn.number > current_turn.number }
      if next_turn
        @current_turn = next_turn
        return next_turn
      end

      next_active_player
      logger.debug "Starting Turn #{@turn_number} - Active Player: #{@players.first}"
      @current_turn = add_turn(number: current_turn.number + 1, active_player: @players.first)
    end

    def next_active_player
      @players = players.rotate(1)
    end

    # The number of the most recent turn (up to and including the current one) that +player+ was the active player for.
    def latest_turn_number_of(player)
      turns.select { |turn| turn.number <= current_turn.number && turn.active_player == player }.map(&:number).max
    end

    def opponents(player)
      players - [player]
    end

    def remaining_players
      players.reject(&:lost?)
    end

    # Rule 104.3: the game ends when at most one player is left (in a game of more than one player).
    def over?
      players.size > 1 && remaining_players.size <= 1
    end

    # Rule 104.4a: if every remaining player loses at the same time, the game is a draw.
    # State-based actions make players lose together, so this is true after such a pass.
    def drawn?
      players.any? && remaining_players.empty?
    end

    def winner
      remaining_players.first if over? && !drawn?
    end

    def make_monarch!(player)
      return if monarch == player

      @monarch = player
      notify!(Events::PlayerBecameMonarch.new(player: player))
    end

    def ring_emblem_for(player)
      emblems.find { |emblem| emblem.is_a?(Emblem::TheRing) && emblem.owner == player }
    end

    def the_ring_tempts!(player)
      emblem = ring_emblem_for(player)
      unless emblem
        emblem = Emblem::TheRing.new(game: self, owner: player)
        add_emblem(emblem)
      end
      emblem.gain_next_ability!

      notify!(Events::TheRingTemptsPlayer.new(player: player))

      add_choice(Choice::RingBearer.new(player: player)) if player.creatures.any?
    end

    def receive_event(event)
      case event
      when Events::CombatDamageDealt
        if monarch && event.target == monarch && event.source.respond_to?(:controller) && event.source.controller != monarch
          make_monarch!(event.source.controller)
        end
      when Events::BeginningOfEndStep
        monarch.draw! if monarch == event.active_player
      end
    end

    def any_target
      battlefield.creatures + battlefield.planeswalkers + players
    end

    def add_effect(effect)
      effect = Game::ReplacementEffectResolver.new(game: self).resolve(effect)

      logger.debug "Resolving effect: #{effect}"
      effect.resolve!
    end

    def choose_replacement_effect(effect:, replacement_effects:, replacement_context: nil)
      chooser = replacement_effect_chooser_for(effect, replacement_context)
      if chooser
        chooser.choose_replacement_effect(
          effect: effect,
          replacement_context: replacement_context,
          replacement_effects: replacement_effects,
        )
      else
        replacement_effects.first
      end
    end

    def replacement_effect_sources
      Game::ReplacementEffectSources.new(game: self).all
    end

    # Rule 704.3: perform state-based actions repeatedly until none apply, then check state triggers.
    def check_state_based_actions!
      return if @checking_state_based_actions

      @checking_state_based_actions = true
      begin
        loop do
          battlefield.map(&:apply_continuous_effects!)
          sba_changed = StateBasedActions.new(game: self).perform!

          if stack.pending_choices?
            # Choice::OrderTriggers is pure queuing plumbing (there's no real agent yet
            # to make this decision), so it auto-resolves transparently here rather than
            # blocking every checkpoint call site on it. Any other pending choice is a
            # real decision and stops the loop for the caller to resolve. Checked before
            # #put_pending_triggers_on_stack! below (not just after) so a still-pending
            # OrderTriggers choice for a player's remaining triggers is resolved before
            # any more of that player's (or another player's) triggers are queued --
            # otherwise a second call could re-batch the same not-yet-placed triggers
            # into a duplicate choice, corrupting resolution order.
            choice = choices.first
            break unless choice.is_a?(Choice::OrderTriggers)
            resolve_choice!(target: choice.target_choices.first)
            next
          end

          triggers_changed = queue_triggers? && put_pending_triggers_on_stack!
          break unless sba_changed || triggers_changed
        end
        check_for_state_triggered_abilities
      ensure
        @checking_state_based_actions = false
      end
    end
    alias_method :tick!, :check_state_based_actions!

    # Called after each action, stack resolution and choice. SBAs are only checked when a player would
    # receive priority, so they wait while a choice is still pending (resolution is not finished yet).
    def state_based_actions_checkpoint!
      check_state_based_actions! unless stack.pending_choices?
    end

    # Resolves the stack (and, transitively, the trigger queue) to quiescence, for
    # callers -- mainly specs, and raw engine calls made outside Turn#take_action --
    # that skip the normal checkpoints and want "let everything that's already queued
    # fully resolve" without simulating real priority passes. Stops as soon as a real
    # (non-OrderTriggers) choice is pending, leaving it for the caller to resolve.
    def settle!
      loop do
        check_state_based_actions!
        break if stack.pending_choices?
        break if stack.empty?
        stack.resolve!
      end
    end

    # Rule 603.8
    def check_for_state_triggered_abilities
      abilities = battlefield.flat_map(&:state_triggered_abilities).select(&:condition_met?)
      # Sub rule: A state-triggered ability doesn't trigger again until the ability has resolved, has been countered, or has otherwise left the stack.
      abilities = abilities.reject { |ability| stack.include?(ability) }
      abilities.each do
        stack.add(_1)
      end
    end

    def graveyard_cards
      CardList.new(players.flat_map { _1.graveyard.items })
    end

    private

    # The next player in turn order (skipping players who have lost).
    def player_after(player)
      order = remaining_players
      order[(order.index(player) + 1) % order.size]
    end

    # Rule 603.3b: each player, in APNAP order, puts the triggered abilities they
    # control on the stack (choosing their own order for simultaneous ones). +players+
    # is already active-player-first (see #next_active_player), so no separate APNAP
    # ordering is needed. Only one player's batch is placed per call: a player with
    # 2+ pending triggers gets a Choice::OrderTriggers, which pauses further draining
    # (via the pending_choices? check in #check_state_based_actions!) until resolved.
    def put_pending_triggers_on_stack!
      player = players.find { |p| pending_triggers.any? { |ability| ability.controller == p } }
      return false unless player

      triggers = pending_triggers.select { |ability| ability.controller == player }

      if triggers.one?
        pending_triggers.delete(triggers.first)
        stack.add(triggers.first)
      else
        add_choice(Choice::OrderTriggers.new(player: player, triggers: triggers))
      end

      true
    end

    def replacement_effect_chooser_for(effect, replacement_context = nil)
      if replacement_context&.affected_controller
        return replacement_context.affected_controller
      end

      if effect.respond_to?(:target)
        target = effect.target
        return target if target.respond_to?(:player?) && target.player?
        return target.controller if target.respond_to?(:controller)
      end

      if effect.respond_to?(:controller)
        return effect.controller
      end

      if effect.respond_to?(:permanent) && effect.permanent.respond_to?(:controller)
        return effect.permanent.controller
      end

      nil
    end
  end
end
