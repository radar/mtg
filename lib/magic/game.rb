module Magic
  class Game
    extend Forwardable

    attr_reader :logger, :battlefield, :exile, :turns, :stack, :players, :emblems, :current_turn

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
      logger: nil
    )
      @logger = Logger.new(STDOUT)
      @battlefield = battlefield
      @exile = exile
      @stack = Stack.new(logger: @logger)
      @effects = effects
      @logger.level = ENV['LOG_LEVEL'] || "INFO"
      @player_count = 0
      @players = players
      @emblems = []
      @turns = []
    end

    def add_players(*players)
      players.each(&method(:add_player))
    end

    def add_player(player)
      @player_count += 1
      @players << player
      player.join_game(self)
    end

    def add_emblem(emblem)
      @emblems << emblem
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

    def opponents(player)
      players - [player]
    end

    def any_target
      battlefield.creatures + battlefield.planeswalkers + players
    end

    def add_effect(effect)
      effect = Game::ReplacementEffectResolver.new(game: self).resolve(effect)

      logger.debug "Resolving effect: #{effect}"
      effect.resolve!
    end

    def choose_replacement_effect(effect:, replacement_effects:)
      chooser = replacement_effect_chooser_for(effect)
      if chooser
        chooser.choose_replacement_effect(effect: effect, replacement_effects: replacement_effects)
      else
        replacement_effects.first
      end
    end

    def tick!
      battlefield.map(&:apply_continuous_effects!)
      check_for_state_triggered_abilities
      move_dead_creatures_to_graveyard
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

    def move_dead_creatures_to_graveyard
      battlefield.creatures.dead.each(&:destroy!)
    end

    private

    def replacement_effect_chooser_for(effect)
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
