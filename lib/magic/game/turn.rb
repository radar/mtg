module Magic
  class Game
    class Turn
      extend Forwardable

      attr_reader :active_player, :step, :number, :events

      def_delegators :@game, :battlefield, :emblems
      def_delegators :@combat, :declare_attacker, :declare_blocker, :can_block?, :attacks

      def initialize(number: 1, game: Magic::Game.new, active_player: Magic::Player.new)
        @step = :untap
        @number = number
        @logger = Logger.new(STDOUT)
        @logger.formatter = -> (_, _, _, msg) { "#{msg}\n" }
        @game = game
        @active_player = active_player
        @events = []
        @combat = CombatPhase.new(game: game)
        @after_attackers_declared_callbacks = []
      end

      def at_step?(other_step)
        step == other_step
      end

      def untap!
        battlefield.untap { |cards| cards.controlled_by(active_player) }
      end

      def upkeep!
        @step = :upkeep
        beginning_of_upkeep!
      end

      def draw!
        @step = :draw
        active_player.draw!
      end

      def first_main!
        @step = :first_main
      end

      def beginning_of_combat!
        @step = :beginning_of_combat

        notify!(
          Events::BeginningOfCombat.new(active_player: active_player)
        )

        @combat = CombatPhase.new(game: self)
      end

      def declare_attackers!
        @step = :declare_attackers
      end

      def attackers_declared!
        @step = :attackers_declared

        attackers_declared = Events::AttackersDeclared.new(
          active_player: active_player,
          turn: number,
          attackers: combat.attacks.map(&:attacker),
        )

        notify!(attackers_declared)

        # The above notification might create further attacking creatures, so we need to declare again.
        declare_attackers! if combat.attackers_without_targets?
      end

      def declare_blockers!
        @step = :declare_blockers
      end

      def first_strike!
        @step = :first_strike
        combat.deal_first_strike_damage
        move_dead_creatures_to_graveyard
      end

      def combat_damage!
        @step = :combat_damage
        combat.deal_combat_damage
        move_dead_creatures_to_graveyard
      end

      def end_of_combat!
        @step = :end_of_combat
      end

      def second_main!
        @step = :second_main
      end

      def end!
        @step = :end
        notify!(
          Events::BeginningOfEndStep.new(active_player: active_player)
        )
      end

      def cleanup!
        battlefield.creatures.each(&:cleanup!)
      end

      def beginning_of_upkeep!
        active_player.reset_lands_played

        notify!(
          Events::BeginningOfUpkeep.new
        )
      end

      def add_attacking_token(token_class)
        token = token_class.new(game: game, controller: active_player)
        token.resolve!
        token.tap!

        combat.declare_attacker(token)
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

      def move_dead_creatures_to_graveyard
        battlefield.creatures.dead.each(&:destroy!)
      end
    end
  end
end
