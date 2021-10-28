module Magic
  class Game
    class Turn

      class Trigger
        attr_reader :action, :until_eot

        def initialize(action:, until_eot: true)
          @action = action
          @until_eot = until_eot
        end

        def until_eot?
          until_eot
        end

        def resolve
          action.call
        end
      end

      include AASM
      extend Forwardable

      attr_reader :active_player, :number

      def_delegators :@game, :battlefield, :emblems
      def_delegators :@combat, :declare_attacker, :declare_blocker, :can_block?, :attacks

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
        state :cleanup, after_enter: -> { battlefield.creatures.each(&:cleanup!) }

        after_all_transitions :log_step_change

        event :upkeep do
          transitions from: :untap, to: :upkeep
        end

        event :draw do
          transitions from: :upkeep, to: :draw
        end

        event :first_main do
          transitions from: :draw, to: :first_main
        end

        event :beginning_of_combat do
          transitions from: :first_main, to: :beginning_of_combat
        end

        event :declare_attackers do
          transitions from: :beginning_of_combat, to: :declare_attackers
        end

        event :attackers_declared do
          before do
            attackers = combat.attacks.map(&:attacker)
            attackers.each(&:whenever_this_attacks)
            @after_attackers_declared_callbacks.each(&:call)
          end
          transitions from: :declare_attackers, to: :declare_attackers, guard: -> { combat.attackers_without_targets? }
          transitions from: :declare_attackers, to: :declare_blockers, guard: -> { combat.attackers_declared? }
        end

        event :extra_attackers_declared do
          transitions from: :declare_attackers, to: :declare_blockers, guard: -> { combat.attackers_declared? }
        end

        event :declare_blockers do
          transitions from: :declare_attackers, to: :declare_blockers
        end

        event :first_strike do
          transitions from: :declare_blockers, to: :first_strike, after: [
            -> { combat.deal_first_strike_damage },
            -> { move_dead_creatures_to_graveyard },
          ]
        end

        event :combat_damage do
          transitions from: :first_strike, to: :combat_damage, after: [
            -> { combat.deal_combat_damage },
            -> { move_dead_creatures_to_graveyard },
          ]
        end

        event :finish_combat do
          transitions from: [:combat_damage, :declare_attackers], to: :end_of_combat
        end

        event :second_main do
          transitions from: :end_of_combat, to: :second_main
        end

        event :end do
          transitions from: :second_main, to: :end_of_turn
        end

        event :cleanup do
          transitions from: :end_of_turn, to: :cleanup
        end
      end

      def initialize(number: 1, game: Magic::Game.new, active_player: Magic::Player.new)
        @number = number
        @logger = Logger.new(STDOUT)
        @logger.formatter = -> (_, _, _, msg) { "#{msg}\n" }
        @game = game
        @active_player = active_player
        @events = []
        @combat = CombatPhase.new(game: game)
        @after_attackers_declared_callbacks = []
      end

      def after_attackers_declared(callback)
        @after_attackers_declared_callbacks << callback
      end

      def log_step_change
        from = aasm(:step).from_state
        to = aasm(:step).to_state
        puts "changing from #{from} to #{to} (event: #{aasm(:step).current_event})"
      end

      def at_step?(other_step)
        step == other_step
      end

      def step
        aasm(:step).current_state
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

      def add_attacking_token(token_class)
        token = token_class.new(game: game, controller: active_player)
        token.resolve!
        token.tap!

        declare_attacker(token)
      end

      def notify!(*events)
        events.each do |event|
          track_event(event)
          logger.debug "EVENT: #{event.inspect}"
          emblems.each { |emblem| emblem.receive_event(event) }
          battlefield.receive_event(event)
        end
      end

      private

      attr_reader :game, :logger, :combat, :after_step_triggers

      def track_event(event)
        @events << event
      end

      def untap_active_player_permanents
        battlefield.untap { |cards| cards.controlled_by(active_player) }
      end

      def move_dead_creatures_to_graveyard
        battlefield.creatures.dead.each(&:destroy!)
      end
    end
  end
end
