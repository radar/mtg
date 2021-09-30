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

        def blocked!
          @blocked = true
        end

        def resolve
          return if blocked?
          return if attacker.dead?
          target.take_damage(attacker.power)
          puts "#{attacker} attacks #{target} for #{attacker.power}"
        end
      end

      attr_reader :attacks

      def initialize
        @attacks = []
      end

      def declare_attacker(attacker, target:)
        attacker.tap!
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
        deal_damage(@attacks)
      end

      def fatalities
        dead_attackers = attacks.map(&:attacker).select(&:dead?)
        dead_blockers = attacks.flat_map(&:blockers).select(&:dead?)

        dead_attackers + dead_blockers
      end


      private

      def deal_damage(attacks)
        attacks.each do |attack|
          attack.blockers.each do |blocker|
            attack.blocked!
            attacker = attack.attacker
            attacker.fight(blocker)
            puts "#{blocker.name} damages #{attacker.name} for #{blocker.power}"
            blocker.fight(attacker)
            puts "#{attacker.name} damages #{blocker.name} for #{attacker.power}"
          end

          attack.resolve
        end
      end

    end
  end
end
