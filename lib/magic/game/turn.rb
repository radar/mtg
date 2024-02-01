module Magic
  class Game
    class Turn
      extend Forwardable

      attr_reader :active_player, :number, :events, :combat, :actions

      def_delegators :@game, :logger, :battlefield, :emblems, :players
      def_delegators :@combat, :declare_attacker, :declare_blocker, :choose_attacker_target, :can_block?, :attacks, :attacking?

      state_machine :step, initial: :beginning do

        after_transition do |turn, transition|
          turn.logger.debug "STEP: #{transition.from} -> #{transition.to}"
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
            Events::BeginningOfUpkeep.new
          )
        end

        after_transition to: :draw do |turn|
          turn.notify!(
            Events::DrawStep.new
          )
          turn.active_player.draw!
        end

        after_transition to: :first_main do |turn|
          turn.notify!(
            Events::FirstMainPhase.new(active_player: turn.active_player)
          )
        end

        after_transition to: :beginning_of_combat do |turn|
          turn.notify!(
            Events::BeginningOfCombat.new(active_player: turn.active_player)
          )
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

        after_transition to: :end do |turn|
          turn.notify!(
            Events::BeginningOfEndStep.new(active_player: turn.active_player)
          )
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
        @events = []
        @combat = CombatPhase.new(game: game)
        super()
      end

      def take_action(action)
        @actions << action
        logger.debug "ACTION: #{action.inspect}"
        action.perform
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
      end

      def deal_combat_damage
        combat.deal_first_strike_damage
        game.tick!
        combat.deal_combat_damage
        game.tick!
      end

      def notify!(*events)
        events.each do |event|
          logger.debug "EVENT: #{event.inspect}"
          track_event(event)
          replacement_sources = replacement_effect_sources(event)
          # TODO: Handle multiple replacement effects -- player gets to choose which one to pick
          if replacement_sources.any?
            logger.debug "  EVENT REPLACED! Replaced by: #{replacement_sources.first}"
            event = replacement_sources.first.handle_replacement_effect(event)
          end

          if event
            emblems.each { |emblem| emblem.receive_event(event) }
            battlefield.receive_event(event)
            players.each { |player| player.receive_event(event) }
          end
        end
      end

      def replacement_effect_sources(event)
        battlefield.cards.select { |card| card.has_replacement_effect?(event) }
      end

      def spells_cast
        events.select { |event| event.is_a?(Events::SpellCast) }
      end

      def can_cast_sorcery?(player)
        game.stack.empty? && active_player == player
      end


      private

      attr_reader :game

      def track_event(event)
        @events << event
      end
    end
  end
end
