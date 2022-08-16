module Magic
  class Game
    class Turn
      extend Forwardable

      attr_reader :active_player, :number, :events, :combat, :actions

      def_delegators :@game, :battlefield, :emblems, :players
      def_delegators :@combat, :declare_attacker, :declare_blocker, :choose_attacker_target, :can_block?, :attacks

      state_machine :step, initial: :beginning do
        event :untap do
          transition beginning: :untap
        end

        after_transition to: :untap do |turn|
          turn.battlefield.cards.controlled_by(turn.active_player).each(&:untap!)
        end

        after_transition to: :upkeep do |turn|
          turn.notify!(
            Events::BeginningOfUpkeep.new
          )
        end

        after_transition to: :draw do |turn|
          turn.active_player.draw!
        end

        after_transition to: :beginning_of_combat do |turn|
          turn.notify!(
            Events::BeginningOfCombat.new(active_player: turn.active_player)
          )
        end

        after_transition to: :combat_damage do |turn|
          turn.deal_combat_damage
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
        puts "ACTION: #{action.inspect}"
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

        notify!(Events::AttackersDeclared.new(
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

      def deal_combat_damage
        combat.deal_first_strike_damage
        game.tick!
        combat.deal_combat_damage
        game.tick!
      end

      def notify!(*events)
        events.each do |event|
          track_event(event)
          logger.debug "EVENT: #{event.inspect}"
          next if event.is_a?(Events::DamageDealt) && battlefield.any? { |permanent| permanent.respond_to?(:prevent_damage!) && permanent.prevent_damage!(event) }
          emblems.each { |emblem| emblem.receive_event(event) }
          battlefield.receive_event(event)
          players.each { |player| player.receive_event(event) }
        end
      end

      def spells_cast
        events.select { |event| event.is_a?(Events::SpellCast) }
      end

      private

      attr_reader :game, :logger

      def track_event(event)
        @events << event
      end
    end
  end
end
