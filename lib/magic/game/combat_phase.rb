module Magic
  class Game
    class CombatPhase
      class AttackerHasProtection < StandardError; end
      class IllegalBlock < StandardError; end
      class IllegalDamageAssignment < StandardError; end

      class Attack
        attr_reader :attacker, :target, :blockers, :damage_assignment

        def initialize(attacker:, target:)
          @attacker = attacker
          @target = target
          @blockers = []
          @blocked = false
          @damage_assignment = nil
        end

        def retarget(new_target)
          @target = new_target
        end

        def declare_blocker(blocker)
          @blockers << blocker
          @blocked = true
        end

        # Rule 509.1h: an attacking creature stays blocked even if every creature blocking it
        # leaves combat.
        def blocked?
          @blocked
        end

        # The player (or the controller of the planeswalker or battle) being attacked.
        def defending_player
          return if target.nil?

          target.player? ? target : target.controller
        end

        def remaining_blockers
          blockers.select { |blocker| CombatPhase.in_combat?(blocker) }
        end

        def assign_damage!(assignment)
          reason = assignment_illegal_reason(assignment, attacker.power)
          raise IllegalDamageAssignment, reason if reason

          @damage_assignment = assignment
        end

        # Rule 510.1c-d: how much damage this attacker deals to each recipient in this damage step.
        def damage_assignments
          power = attacker.power
          return {} unless power.positive?
          return { target => power } unless blocked?

          if damage_assignment && assignment_illegal_reason(damage_assignment, power).nil?
            return damage_assignment.reject { |_, amount| amount.zero? }
          end

          default_damage_assignments(power)
        end

        # Rule 510.1d: each blocker deals its combat damage to the attacker it blocks.
        def blocker_damage_assignments(blocker)
          return {} unless blocker.power.positive? && CombatPhase.in_combat?(attacker)

          { attacker => blocker.power }
        end

        def lethal_damage_for(blocker)
          return 1 if attacker.deathtouch?

          [blocker.toughness - blocker.damage, 0].max
        end

        private

        # Lethal damage to each blocker in the order they were declared. Leftover damage goes to the
        # player or permanent under attack if the attacker has trample, or to the last blocker if not.
        def default_damage_assignments(power)
          remaining = remaining_blockers
          if remaining.empty?
            return attacker.trample? ? { target => power } : {}
          end

          assignments = Hash.new(0)
          remaining.each do |blocker|
            assigned = [lethal_damage_for(blocker), power].min
            assignments[blocker] += assigned
            power -= assigned
          end

          if power.positive?
            recipient = attacker.trample? ? target : remaining.last
            assignments[recipient] += power
          end

          assignments.reject { |_, amount| amount.zero? }
        end

        def assignment_illegal_reason(assignment, power)
          remaining = remaining_blockers
          recipients = assignment.keys
          return "#{attacker.name} isn't blocked" unless blocked?
          return "damage amounts can't be negative" if assignment.values.any?(&:negative?)
          return "#{attacker.name} must assign exactly #{power} damage" unless assignment.values.sum == power

          unexpected = recipients - remaining - [target]
          return "#{unexpected.map(&:name).join(", ")} isn't blocking #{attacker.name}" if unexpected.any?
          return unless recipients.include?(target) && assignment[target].positive?
          return "#{attacker.name} doesn't have trample" unless attacker.trample?

          short = remaining.find { |blocker| assignment.fetch(blocker, 0) < lethal_damage_for(blocker) }
          "#{short.name} must be assigned lethal damage before damage tramples over" if short
        end
      end

      attr_reader :game, :attacks

      def self.in_combat?(permanent)
        !permanent.zone.nil?
      end

      def initialize(game:)
        @game = game
        @attacks = []
        @first_strike_damage_dealers = []
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

      def blocking?(permanent)
        @attacks.any? { |attack| attack.blockers.include?(permanent) }
      end

      def attackers_without_targets?
        @attacks.any? { |attack| attack.target.nil? }
      end

      def attackers_declared?
        @attacks.any?
      end

      def can_block?(attacker:, blocker:)
        illegal_block_reason(attacker: attacker, blocker: blocker).nil?
      end

      # Rule 509.1a-b: restrictions checked for each blocker as it is declared. Restrictions that
      # depend on the whole set of blocks (menace) are checked by `validate_blocks!`.
      def illegal_block_reason(attacker:, blocker:)
        attack = attack_for_attacker(attacker)
        return "#{attacker.name} isn't attacking" unless attack
        return "#{blocker.name} isn't a creature" unless blocker.creature?
        return "#{blocker.name} is tapped" if blocker.tapped?

        defending_player = attack.defending_player
        if defending_player && !blocker.controller?(defending_player)
          return "#{blocker.name} isn't controlled by the defending player"
        end

        return "#{blocker.name} is already blocking" if blocking?(blocker)
        return "#{attacker.name} has protection from #{blocker.name}" if attacker.protected_from?(blocker)
        return "#{blocker.name} can't block #{attacker.name}" unless blocker.can_block?(attacker)
        return "#{attacker.name} can't be blocked by #{blocker.name}" unless attacker.can_be_blocked?(blocker)

        if attacker.flying? && !blocker.flying? && !blocker.reach?
          return "#{attacker.name} has flying, and #{blocker.name} has neither flying nor reach"
        end

        if attacker.skulk? && blocker.power > attacker.power
          return "#{attacker.name} has skulk, and #{blocker.name} has greater power"
        end

        nil
      end

      def declare_blocker(blocker, attacker:)
        raise AttackerHasProtection if attacker.protected_from?(blocker)

        reason = illegal_block_reason(attacker: attacker, blocker: blocker)
        raise IllegalBlock, reason if reason

        attack = attack_for_attacker(attacker)
        attack.declare_blocker(blocker)
        game.notify!(Events::CreatureBlocked.new(attacker: attacker, blocker: blocker))
      end

      # Rule 509.1c: checked once all blockers are declared.
      def validate_blocks!
        @attacks.each do |attack|
          if attack.attacker.menace? && attack.blockers.count == 1
            raise IllegalBlock, "#{attack.attacker.name} has menace and can't be blocked except by two or more creatures"
          end
        end
      end

      # Rule 510.5: lets the attacking player choose how a blocked attacker divides its damage
      # between the creatures blocking it (and, with trample, the player or permanent it attacks).
      def assign_combat_damage(attacker, assignment)
        attack = attack_for_attacker(attacker)
        raise IllegalDamageAssignment, "#{attacker.name} isn't attacking" unless attack

        attack.assign_damage!(assignment)
      end

      # Rule 510.4: only creatures with first strike or double strike deal damage in this step.
      def deal_first_strike_damage
        @first_strike_damage_dealers = combatants.select { |creature| creature.first_strike? || creature.double_strike? }
        deal_damage { |creature| @first_strike_damage_dealers.include?(creature) }
      end

      # Rule 510.4: creatures that didn't deal first-strike damage, plus those with double strike.
      def deal_combat_damage
        deal_damage { |creature| creature.double_strike? || !@first_strike_damage_dealers.include?(creature) }
      end

      private

      def combatants
        @attacks.flat_map { |attack| [attack.attacker, *attack.blockers] }.uniq
      end

      # Rule 510.1-2: work out all of the damage for this step first, then deal it together.
      def deal_damage(&deals_damage)
        assignments = []

        @attacks.each do |attack|
          if self.class.in_combat?(attack.attacker) && deals_damage.call(attack.attacker)
            attack.damage_assignments.each { |recipient, amount| assignments << [attack.attacker, recipient, amount] }
          end

          attack.remaining_blockers.each do |blocker|
            next unless deals_damage.call(blocker)

            attack.blocker_damage_assignments(blocker).each { |recipient, amount| assignments << [blocker, recipient, amount] }
          end
        end

        assignments.each { |source, recipient, amount| source.fight(recipient, amount) }
      end
    end
  end
end
