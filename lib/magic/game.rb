module Magic
  class Game
    include AASM
    extend Forwardable

    attr_reader :logger, :battlefield, :stack, :players, :step, :attacks

    def_delegators :@stack, :effects, :add_effect, :resolve_effect
    def_delegators :@combat, :declare_attacker, :declare_blocker, :deal_combat_damage, :fatalities

    def initialize(battlefield: Battlefield.new, stack: Stack.new, effects: [], players: [], step: Step.new(game: self))
      @logger = Logger.new(STDOUT)
      @logger.formatter = -> (_, _, _, msg) { "#{msg}\n" }
      @step = step
      @battlefield = battlefield
      @stack = stack
      @effects = effects
      @players = players
      @combat = nil
    end

    def add_player
      Magic::Player.new.tap do |player|
        @players << player
        player.join_game(self)
      end
    end

    def add_player(**args)
      Magic::Player.new(**args).tap do |player|
        @players << player
        player.join_game(self)
      end
    end

    def next_step
      step.next
    end

    def notify!(*events)
      events.each do |event|
        logger.debug "EVENT: #{event.inspect}"
        battlefield.receive_event(event)
      end
    end

    def active_player
      players.first
    end

    def change_active_player
      @players = players.rotate(1)
    end

    def begin_combat!
      @combat = CombatPhase.new
    end

    def deal_damage_to_opponents(player, damage)
      opponents = players - [player]
      opponents.each { |opponent| opponent.take_damage(damage) }
    end

    def untap_active_player_permanents
      battlefield.untap { |cards| cards.controlled_by(active_player) }
    end

    def move_dead_creatures_to_graveyard
      fatalities.each(&:destroy!)
    end
  end
end
