module Magic
  class Game
    class Turn
      include AASM
      extend Forwardable

      attr_reader :active_player, :number

      def_delegators :@game, :battlefield, :emblems
      def_delegators :@combat, :declare_attacker, :declare_blocker, :can_block?

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
        end

        event :go_to_beginning_of_combat do
          transitions to: :beginning_of_combat
        end
      end

      def initialize(number:, game:, active_player:)
        @number = number
        @logger = Logger.new(STDOUT)
        @logger.formatter = -> (_, _, _, msg) { "#{msg}\n" }
        @game = game
        @active_player = active_player
        @events = []
        @combat = CombatPhase.new(game: game)
      end

      def log_step_change
        from = aasm(:step).from_state
        to = aasm(:step).to_state
        puts "changing from #{from} to #{to} (event: #{aasm(:step).current_event})"
      end

      def at_step?(step)
        current_step == step
      end

      def current_step
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

      def attackers_declared!
        attackers = combat.attacks.map(&:attacker)
        attackers.each do |attacker|
          notify!(
            Events::AttackingCreature.new(creature: attacker)
          )
        end
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

      attr_reader :game, :logger, :combat

      def track_event(event)
        @events << event
      end

      def untap_active_player_permanents
        battlefield.untap { |cards| cards.controlled_by(active_player) }
      end

      def run_after_step_triggers
        last_step = aasm(:step).from_state
        game.after_step_triggers[last_step].each { |trigger| trigger.resolve(self) }
      end

      def move_dead_creatures_to_graveyard
        battlefield.creatures.dead.each(&:destroy!)
      end

      def cleanup!
        battlefield.creatures.each(&:cleanup!)
      end
    end
  end
end
