module Magic
  class Game
    class CombatPhase
      include AASM

      aasm do
        state :beginning_of_combat, initial: true
        state :declare_attackers
        state :declare_blockers
        state :first_strike
        state :combat_damage
        state :end_of_combat

        event :next_step do
          transitions from: :beginning_of_combat, to: :declare_attackers
          transitions from: :declare_attackers, to: :declare_blockers
          transitions from: :declare_blockers, to: :first_strike
          transitions from: :first_strike, to: :combat_damage, after: :deal_combat_damage
          transitions from: :combat_damage, to: :end_of_combat
        end
      end

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
        end
      end

      attr_reader :active_player, :opponents, :attacks

      def initialize(active_player:, opponents: [])
        @active_player = active_player
        @opponents = opponents
        @attacks = []
      end

      def declare_attacker(attacker, target:)
        @attacks << Attack.new(attacker: attacker, target: target)
      end

      def declare_blocker(blocker, target:)
        attack = @attacks.find do |attack|
          attack.attacker == target
        end
        attack.declare_blocker(blocker)
      end

      def deal_combat_damage
        @attacks.each do |attack|
          attack.blockers.each do |blocker|
            attack.blocked!
            attack.attacker.take_damage(blocker.power)
            blocker.take_damage(attack.attacker.power)
          end

          attack.resolve
        end
      end

      def fatalities
        dead_attackers = attacks.map(&:attacker).select(&:dead?)
        dead_blockers = attacks.flat_map(&:blockers).select(&:dead?)

        dead_attackers + dead_blockers
      end
    end
  end
end
