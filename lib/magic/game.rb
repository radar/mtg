module Magic
  class Game
    include AASM
    extend Forwardable

    attr_reader :logger, :battlefield, :stack, :players, :attacks, :emblems, :combat, :after_step_triggers

    def_delegators :@stack, :effects, :add_effect, :resolve_effect, :next_effect

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
      state :cleanup, after_enter: -> { cleanup! }

      after_all_transitions :log_step_change
      after_all_transitions :run_after_step_triggers

      event :next do
        transitions from: :untap, to: :upkeep
        transitions from: :upkeep, to: :draw
        transitions from: :draw, to: :first_main
        transitions from: :first_main, to: :beginning_of_combat
        transitions from: :beginning_of_combat, to: :declare_attackers
        transitions from: :declare_attackers, to: :declare_blockers, guard: -> { combat.attackers_declared? }, after: [
          -> { attackers_declared! }
        ]
        transitions from: :declare_attackers, to: :end_of_combat
        transitions from: :declare_blockers, to: :first_strike, after: [
          -> { combat.deal_first_strike_damage },
          -> { move_dead_creatures_to_graveyard },
        ]
        transitions from: :first_strike, to: :combat_damage, after: [
          -> { combat.deal_combat_damage },
          -> { move_dead_creatures_to_graveyard },
        ]
        transitions from: [:combat_damage, :declare_attackers], to: :end_of_combat
        transitions from: :beginning_of_combat, to: :end_of_combat
        transitions from: :end_of_combat, to: :second_main
        transitions from: :second_main, to: :end_of_turn
        transitions from: :end_of_turn, to: :cleanup
        transitions from: :cleanup, to: :untap, after: -> do
          change_active_player
        end
      end

      event :go_to_beginning_of_combat do
        transitions to: :beginning_of_combat
      end
    end

    class Trigger
      attr_reader :action, :until_eot

      def initialize(action:, until_eot:)
        @action = action
        @until_eot = until_eot
      end

      def until_eot?
        until_eot
      end

      def resolve(game)
        action.resolve(game)
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
      @emblems = []
      @after_step_triggers = Hash.new { |h, k| h[k] = [] }
    end

    def log_step_change
      from = aasm(:step).from_state
      to = aasm(:step).to_state
      puts "changing from #{from} to #{to} (event: #{aasm(:step).current_event})"
    end

    def run_after_step_triggers
      last_step = aasm(:step).from_state
      after_step_triggers[last_step].each { |trigger| trigger.resolve(self) }
    end

    def at_step?(step)
      current_step == step
    end

    def current_step
      aasm(:step).current_state
    end

    def after_step(step, action, until_eot: true)
      @after_step_triggers[step] << Trigger.new(
        action: action,
        until_eot: until_eot,
      )
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

    def add_emblem(emblem)
      @emblems << emblem
    end

    def start!
      players.each do |player|
        7.times { player.draw! }
      end
    end

    def notify!(*events)
      events.each do |event|
        logger.debug "EVENT: #{event.inspect}"
        emblems.each { |emblem| emblem.receive_event(event) }
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
      active_player.reset_lands_played

      notify!(
        Events::BeginningOfUpkeep.new
      )
    end

    def begin_combat!
      notify!(
        Events::BeginningOfCombat.new(active_player: active_player)
      )

      @combat = CombatPhase.new(game: self)
    end

    def attackers_declared!
      attackers = combat.attacks.map(&:attacker)
      attackers.each do |attacker|
        notify!(
          Events::AttackingCreature.new(creature: attacker)
        )
      end
    end

    def deal_damage_to_opponents(player, damage)
      opponents = players - [player]
      opponents.each { |opponent| opponent.take_damage(damage) }
    end

    def untap_active_player_permanents
      battlefield.untap { |cards| cards.controlled_by(active_player) }
    end

    def move_dead_creatures_to_graveyard
      battlefield.creatures.dead.each(&:destroy!)
    end

    def cleanup!
      battlefield.creatures.each(&:cleanup!)
      until_eot_triggers = after_step_triggers.values.flatten.select { |trigger| trigger.until_eot? }
      after_step_triggers.each do |key, triggers|
        after_step_triggers[key] = triggers.reject { |trigger| until_eot_triggers.include?(trigger) }
      end
    end
  end
end
