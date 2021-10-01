module Magic
  class Game
    class CombatPhase
      include AASM

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

      attr_reader :attacks

      def initialize
        @attacks = []
      end

      def declare_attacker(attacker, target:)
        attacker.tap! unless attacker.vigilant?
        @attacks << Attack.new(attacker: attacker, target: target)
      end

      def attackers_declared?
        @attacks.any?
      end

      def declare_blocker(blocker, target:)
        attack = @attacks.find do |attack|
          attack.attacker == target
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

      def fatalities
        dead_attackers = attacks.map(&:attacker).select(&:dead?)
        dead_blockers = attacks.flat_map(&:blockers).select(&:dead?)

        dead_attackers + dead_blockers
      end


      private

      def deal_damage(attacks)
        attacks.each(&:resolve)
      end
    end
  end
end
