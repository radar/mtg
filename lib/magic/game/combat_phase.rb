module Magic
  class Game
    class CombatPhase
      include AASM

      aasm :step, namespace: :step do
        state :beginning_of_combat, initial: true
        state :declare_attackers
        state :declare_blockers
        state :first_strike
        state :combat_damage
        state :end_of_combat, after_enter: -> { game.next_step! }

        after_all_transitions :log_step_change

        event :next do
          transitions from: :beginning_of_combat, to: :declare_attackers
          transitions from: :declare_attackers, to: :declare_blockers, guard: -> { attackers_declared? }
          transitions from: :declare_attackers, to: :end_of_combat
          transitions from: :declare_blockers, to: :first_strike, after: [
            -> { deal_first_strike_damage },
            -> { game.move_dead_creatures_to_graveyard },
          ]
          transitions from: :first_strike, to: :combat_damage, after: [
            -> { deal_combat_damage },
            -> { game.move_dead_creatures_to_graveyard },
          ]
          transitions from: [:combat_damage, :declare_attackers], to: :end_of_combat
        end
      end

      class AttackerHasProtection < StandardError; end

      class Attack
        attr_reader :attacker, :target, :blockers

        def initialize(attacker:, target:)
          @attacker = attacker
          @target = target
          @blockers = []
          @blocked = false
        end

        def declare_blocker(blocker)
          @blockers << blocker
        end

        def blocked?
          @blocked
        end


        def resolve
          return if attacker.dead?

          damage_output = attacker.power

          if blockers.any?
            blockers.each do |blocker|
              blocker.fight(attacker)
              assigned_damage = [blocker.toughness, damage_output].min
              attacker.fight(blocker, assigned_damage)
              damage_output -= assigned_damage
            end

            attacker.fight(target, damage_output) if attacker.trample?
          else
            attacker.fight(target)
          end
        end
      end

      attr_reader :game, :attacks

      def initialize(game:)
        @game = game
        @attacks = []
      end

      def log_step_change
        puts "COMBAT PHASE: changing from #{aasm(:step).from_state} to #{aasm(:step).to_state} (event: #{aasm(:step).current_event})"
      end


      def at_step?(step)
        aasm(:step).current_state == step
      end

      def declare_attacker(attacker, target:)
        attacker.tap! unless attacker.vigilant?
        @attacks << Attack.new(attacker: attacker, target: target)
      end

      def attackers_declared?
        @attacks.any?
      end

      def can_block?(attacker:, blocker:)
        !attacker.protected_from?(blocker)
      end

      def declare_blocker(blocker, attacker:)
        raise AttackerHasProtection unless can_block?(attacker: attacker, blocker: blocker)

        attack = @attacks.find do |attack|
          attack.attacker == attacker
        end
        attack.declare_blocker(blocker)
      end

      def deal_first_strike_damage
        first_strikers = @attacks.select { |attack| attack.attacker.double_strike? || attack.attacker.first_strike? }
        deal_damage(first_strikers)
      end

      def deal_combat_damage
        attacks_without_first_strike = @attacks.reject { |attack| attack.attacker.first_strike? }
        deal_damage(attacks_without_first_strike)
      end

      private

      def deal_damage(attacks)
        attacks.each(&:resolve)
      end
    end
  end
end
