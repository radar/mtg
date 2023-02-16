module Magic
  class Game
    class CombatPhase
      class AttackerHasProtection < StandardError; end

      class Attack
        attr_reader :attacker, :target, :blockers

        def initialize(attacker:, target:)
          @attacker = attacker
          @target = target
          @blockers = []
          @blocked = false
        end

        def retarget(new_target)
          @target = new_target
        end

        def declare_blocker(blocker)
          @blockers << blocker
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

      def declare_attacker(attacker, target: nil)
        attacker.tap! unless attacker.vigilant?
        attack = attack_for_attacker(attacker)
        if attack
          attack.retarget(target)
        else
          @attacks << Attack.new(attacker: attacker, target: target)
        end
      end

      def choose_attacker_target(attacker, target:)
        attack = attack_for_attacker(attacker)
        attack.retarget(target)
      end

      def attack_for_attacker(attacker)
        @attacks.find { |attack| attack.attacker == attacker }
      end

      def attacking?(permanent)
        !!attack_for_attacker(permanent)
      end

      def attackers_without_targets?
        @attacks.any? { |attack| attack.target.nil? }
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
