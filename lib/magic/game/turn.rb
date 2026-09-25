module Magic
  class Game
    class Turn
      extend Forwardable

      attr_reader :active_player, :number, :events, :combat, :actions

      def_delegators :@game, :logger, :battlefield, :emblems, :players, :settle!
      def_delegators :@combat, :declare_attacker, :declare_blocker, :choose_attacker_target, :can_block?, :attacks, :attacking?

      state_machine :step, initial: :beginning do

        after_transition do |turn, transition|
          turn.logger.debug "STEP: #{transition.from} -> #{transition.to}"
          turn.grant_step_priority!
        end
        event :untap do
          transition beginning: :untap
        end

        after_transition to: :untap do |turn|
          turn.battlefield.phased_out.permanents.controlled_by(turn.active_player).each(&:phase_in!)
          turn.battlefield.permanents.controlled_by(turn.active_player).each(&:untap_during_untap_step)
        end

        after_transition to: :upkeep do |turn|
          turn.notify!(
            Events::BeginningOfUpkeep.new(player: turn.active_player)
          )
          turn.checkpoint!
        end

        after_transition to: :draw do |turn|
          turn.notify!(
            Events::DrawStep.new
          )
          turn.active_player.draw!
          turn.checkpoint!
        end

        after_transition to: :first_main do |turn|
          turn.notify!(
            Events::FirstMainPhase.new(active_player: turn.active_player)
          )
          turn.checkpoint!
        end

        after_transition to: :beginning_of_combat do |turn|
          turn.notify!(
            Events::BeginningOfCombat.new(active_player: turn.active_player)
          )
          turn.checkpoint!
        end

        before_transition to: :combat_damage do |turn|
          turn.combat.validate_blocks!
        end

        after_transition to: :combat_damage do |turn|
          turn.deal_combat_damage
        end

        after_transition from: :declare_attackers, to: :declare_blockers do |turn|
          turn.final_attackers_declared!
        end

        after_transition from: :finalize_attackers do |turn|
          turn.final_attackers_declared!
        end

        after_transition from: :end_of_combat, to: :beginning_of_combat do |turn|
          turn.consume_additional_combat!
        end

        after_transition to: :end do |turn|
          turn.notify!(
            Events::BeginningOfEndStep.new(active_player: turn.active_player)
          )
          turn.checkpoint!
        end

        after_transition to: :cleanup do |turn|
          turn.battlefield.cleanup
        end

        event :upkeep do
          transition untap: :upkeep
        end

        event :draw do
          transition upkeep: :draw
        end

        event :first_main do
          transition draw: :first_main
        end

        event :beginning_of_combat do
          transition first_main: :beginning_of_combat
        end

        event :declare_attackers do
          transition beginning_of_combat: :declare_attackers
        end

        event :attackers_declared do
          transition declare_attackers: :declare_blockers
        end

        event :finalize_attackers do
          transition declare_attackers: :finalize_attackers
        end

        event :attackers_finalized do
          transition declare_attackers: :declare_blockers
          transition finalize_attackers: :declare_blockers
        end

        event :combat_damage do
          transition declare_blockers: :combat_damage
        end

        event :end_of_combat do
          transition declare_attackers: :end_of_combat, unless: -> (turn) { turn.combat.attackers_declared? }
          transition combat_damage: :end_of_combat
        end

        event :second_main do
          transition end_of_combat: :beginning_of_combat, if: :additional_combat_pending?
          transition end_of_combat: :second_main
        end

        event :end do
          transition second_main: :end
          transition all => :end
        end

        event :cleanup do
          transition end: :cleanup
        end
      end

      def initialize(number: 1, game: Magic::Game.new, active_player: Magic::Player.new)
        @number = number
        @logger = Logger.new(STDOUT)
        @logger.formatter = -> (_, _, _, msg) { "#{msg}\n" }
        @game = game
        @active_player = active_player
        @actions = []
        @events = EventLog.new
        @additional_combats = 0
        @combat = CombatPhase.new(game: game)
        super()
      end

      # Rules 502.4, 514.3: nobody receives priority in the untap step, and normally not in cleanup.
      NO_PRIORITY_STEPS = %i[beginning untap cleanup].freeze

      # The event that leaves each step once all players have passed in succession with an empty stack.
      NEXT_STEP_EVENTS = {
        beginning: :untap,
        untap: :upkeep,
        upkeep: :draw,
        draw: :first_main,
        first_main: :beginning_of_combat,
        beginning_of_combat: :declare_attackers,
        declare_attackers: :attackers_declared!,
        finalize_attackers: :attackers_finalized,
        declare_blockers: :combat_damage,
        combat_damage: :end_of_combat,
        end_of_combat: :second_main,
        second_main: :end,
        end: :cleanup,
      }.freeze

      # What happens at each step boundary. Normally: resolve everything that is queued
      # (settle!). With enforce_priority the players must be able to respond, so only
      # SBAs and trigger queueing run, then the active player receives priority.
      def checkpoint!
        if game.enforce_priority?
          game.receive_priority!(active_player)
        else
          game.settle!
        end
      end

      def grant_step_priority!
        if NO_PRIORITY_STEPS.include?(step.to_sym)
          game.revoke_priority!
        else
          game.grant_priority!(active_player)
        end
      end

      # Moves to the next step of the turn. Called by Game#pass_priority! when every
      # player has passed with an empty stack.
      def advance_step!
        event = NEXT_STEP_EVENTS.fetch(step.to_sym) { raise "No next step after #{step}" }
        if event == :attackers_declared!
          combat.attackers_declared? ? attackers_declared! : end_of_combat
        else
          public_send(event)
        end
      end

      def queue_additional_combat!
        @additional_combats += 1
      end

      def additional_combat_pending?
        @additional_combats.positive?
      end

      def consume_additional_combat!
        @additional_combats -= 1
      end

      def take_action(action)
        reason = action.illegal_reason || game.priority_reason(action)
        raise IllegalAction.new(action, reason) if reason

        @actions << action
        logger.debug "ACTION: #{action.inspect}"
        action.perform
        game.priority_action_taken!(action)
        game.state_based_actions_checkpoint!
      end

      def take_actions(*actions)
        actions.each { take_action(_1) }
      end

      def attackers_declared!
        combat.attacks.each do |attack|
          attack_declared = Events::AttackDeclared.new(
            active_player: active_player,
            turn: number,
            attack: attack,
          )
          notify!(attack_declared)
        end

        notify!(Events::PreliminaryAttackersDeclared.new(
          active_player: active_player,
          turn: number,
          attacks: attacks,
        ))
        checkpoint!

        if combat.attackers_without_targets?
          finalize_attackers!
        else
          attackers_finalized!
        end
      end

      def final_attackers_declared!
        notify!(Events::FinalAttackersDeclared.new(
          active_player: active_player,
          turn: number,
          attacks: attacks,
        ))
          game.notify!(*attacks.map { Events::CreatureAttacked.new(attacker: _1.attacker, target: _1.target) })
          checkpoint!
      end

      def deal_combat_damage
        combat.deal_first_strike_damage
        checkpoint!
        combat.deal_combat_damage
        checkpoint!
      end

      def notify!(*events)
        events.each do |event|
          logger.debug "EVENT: #{event.inspect}"
          track_event(event)
          game.event_listeners.dup.each { |listener| listener.receive_event(event) } if event
        end
      end

      def spells_cast
        events.select { |event| event.is_a?(Events::SpellCast) }
      end

      def main_phase?
        step?(:first_main) || step?(:second_main)
      end

      def can_cast_sorcery?(player)
        game.stack.empty? && active_player == player && main_phase?
      end

      def life_gained_by_player(player)
        events.select { |event| event.is_a?(Events::LifeGain) && event.player == player }.sum(&:life)
      end

      private

      attr_reader :game

      def track_event(event)
        @events << event
      end
    end
  end
end
