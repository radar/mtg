module Magic
  class Game
    include AASM
    extend Forwardable

    attr_reader :logger, :battlefield, :stack, :players, :attacks

    def_delegators :@stack, :effects, :add_effect, :resolve_effect, :next_effect
    def_delegators :@combat, :declare_attacker, :declare_blocker, :deal_first_strike_damage, :deal_combat_damage, :fatalities, :attackers_declared?

    aasm :step, namespace: :step do
      state :untap, initial: true, after_enter: -> { untap_active_player_permanents }
      state :upkeep, after_enter: -> { beginning_of_upkeep! }
      state :draw, after_enter: -> { active_player.draw! }
      state :first_main
      state :beginning_of_combat, after_enter: -> { begin_combat! }
      state :declare_attackers
      state :declare_blockers
      state :first_strike
      state :combat_damage
      state :end_of_combat
      state :second_main
      state :end_of_turn
      state :cleanup

      after_all_transitions :log_step_change

      event :next do
        transitions from: :untap, to: :upkeep
        transitions from: :upkeep, to: :draw
        transitions from: :draw, to: :first_main
        transitions from: :first_main, to: :beginning_of_combat
        transitions from: :beginning_of_combat, to: :declare_attackers
        transitions from: :declare_attackers, to: :declare_blockers, guard: -> { attackers_declared? }
        transitions from: :declare_attackers, to: :end_of_combat
        transitions from: :declare_blockers, to: :first_strike, after: [
          -> { deal_first_strike_damage },
          -> { move_dead_creatures_to_graveyard },
        ]
        transitions from: :first_strike, to: :combat_damage, after: [
          -> { deal_combat_damage },
          -> { move_dead_creatures_to_graveyard },
        ]

        transitions from: :combat_damage, to: :end_of_combat
        transitions from: :end_of_combat, to: :second_main
        transitions from: :second_main, to: :end_of_turn
        transitions from: :end_of_turn, to: :cleanup
        transitions from: :cleanup, to: :untap, after: -> { change_active_player; active_player.reset_lands_played }
      end

      event :go_to_beginning_of_combat do
        transitions to: :beginning_of_combat
      end
    end

    def initialize(
      battlefield: Zones::Battlefield.new(owner: self),
      stack: Stack.new,
      effects: [],
      players: []
    )
      @logger = Logger.new(STDOUT)
      @logger.formatter = -> (_, _, _, msg) { "#{msg}\n" }
      @battlefield = battlefield
      @stack = stack
      @effects = effects
      @players = players
      @combat = nil
    end

    def log_step_change
      puts "changing from #{aasm(:step).from_state} to #{aasm(:step).to_state} (event: #{aasm(:step).current_event})"
    end

    def at_step?(step)
      aasm(:step).current_state == step
    end

    def add_player(**args)
      Magic::Player.new(**args).tap do |player|
        @players << player
        player.join_game(self)
      end
    end

    def add_static_ability(ability)
      battlefield.static_abilities.add(ability)
      battlefield.cards.apply_ability(ability)
    end

    def remove_static_abilities_from(card)
      abilities = battlefield.static_abilities.from(card)
      abilities.each do |ability|
        battlefield.static_abilities.remove(ability)
      end
    end

    def start!
      players.each do |player|
        7.times { player.draw! }
      end
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

    def beginning_of_upkeep!
      notify!(
        Events::BeginningOfUpkeep.new
      )
    end

    def begin_combat!
      @combat = CombatPhase.new
      notify!(
        Events::BeginningOfCombat.new
      )
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
