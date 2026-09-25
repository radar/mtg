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

        def remove_blocker(blocker)
          @blockers.delete(blocker)
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

        # Checks the assignment against the damage other creatures are assigning in the same step.
        def assign_damage!(assignment, pending)
          reason = assignment_illegal_reason(assignment, pending)
          raise IllegalDamageAssignment, reason if reason

          @damage_assignment = assignment
        end

        # The division the attacking player chose, if it is still legal in this damage step.
        def chosen_damage_assignments(pending)
          return unless blocked? && damage_assignment && attacker.power.positive?
          return if assignment_illegal_reason(damage_assignment, pending)

          damage_assignment.reject { |_, amount| amount.zero? }
        end

        # Rule 510.1c: lethal damage to each blocker in the order they were declared. Leftover damage
        # goes to the player or permanent under attack if the attacker has trample, or to the last
        # blocker if not.
        def default_damage_assignments(pending)
          power = attacker.power
          return {} unless power.positive?
          return { target => power } unless blocked?

          CombatPhase.divide_damage(attacker, power, remaining_blockers, pending, leftover_to: attacker.trample? ? target : nil)
        end

        def assignment_illegal_reason(assignment, pending)
          power = attacker.power
          remaining = remaining_blockers
          recipients = assignment.keys
          return "#{attacker.name} isn't blocked" unless blocked?
          return "damage amounts can't be negative" if assignment.values.any?(&:negative?)
          return "#{attacker.name} must assign exactly #{power} damage" unless assignment.values.sum == power

          unexpected = recipients - remaining - [target]
          return "#{unexpected.map(&:name).join(", ")} isn't blocking #{attacker.name}" if unexpected.any?
          return unless recipients.include?(target) && assignment[target].positive?
          return "#{attacker.name} doesn't have trample" unless attacker.trample?

          short = remaining.find { |blocker| assignment.fetch(blocker, 0) < pending.lethal_damage(blocker, source: attacker) }
          "#{short.name} must be assigned lethal damage before damage tramples over" if short
        end
      end

      # Combat damage assigned so far in one damage step. Rules 510.1c-d and 702.19c: lethal damage
      # counts damage already marked on a creature and damage other creatures are assigning to it in
      # the same step, and any damage from a deathtouch source is lethal.
      class PendingDamage
        def initialize
          @amounts = Hash.new(0)
          @deathtouched = []
        end

        def add(source, recipient, amount)
          @amounts[recipient] += amount
          @deathtouched << recipient if source.deathtouch? && amount.positive?
        end

        def add_all(source, assignments)
          assignments.each { |recipient, amount| add(source, recipient, amount) }
        end

        def lethal_damage(creature, source:)
          return 0 if @deathtouched.include?(creature)

          needed = creature.toughness - creature.damage - @amounts[creature]
          needed = [needed, 1].min if source.deathtouch?
          [needed, 0].max
        end
      end

      # Lethal damage to each recipient in order, then whatever is left to `leftover_to`, or to the
      # last recipient if there is none.
      def self.divide_damage(source, power, recipients, pending, leftover_to: nil)
        return (leftover_to ? { leftover_to => power } : {}) if recipients.empty?

        assignments = Hash.new(0)
        recipients.each do |recipient|
          assigned = [pending.lethal_damage(recipient, source: source), power].min
          assignments[recipient] += assigned
          power -= assigned
        end
        assignments[leftover_to || recipients.last] += power if power.positive?

        assignments.reject { |_, amount| amount.zero? }
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

      # Rule 506.4: a permanent removed from combat (by regeneration, for instance) stops being an
      # attacking or blocking creature. An attacker that was blocked stays blocked.
      def remove_from_combat(permanent)
        @attacks.reject! { |attack| attack.attacker == permanent }
        @attacks.each { |attack| attack.remove_blocker(permanent) }
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
        attacks_blocked_by(permanent).any?
      end

      def attacks_blocked_by(blocker)
        @attacks.select { |attack| attack.blockers.include?(blocker) }
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

        blocked = attacks_blocked_by(blocker)
        return "#{blocker.name} is already blocking #{attacker.name}" if blocked.include?(attack)
        return "#{blocker.name} is already blocking" if blocked.count >= blocker.maximum_attackers_blocked
        return "#{attacker.name} has protection from #{blocker.name}" if attacker.protected_from?(blocker)
        return "#{blocker.name} can't block #{attacker.name}" unless blocker.can_block?(attacker)
        return "#{attacker.name} can't be blocked by #{blocker.name}" unless attacker.can_be_blocked?(blocker)

        if attacker.flying? && !blocker.flying? && !blocker.reach?
          return "#{attacker.name} has flying, and #{blocker.name} has neither flying nor reach"
        end

        if attacker.skulk? && blocker.power > attacker.power
          return "#{attacker.name} has skulk, and #{blocker.name} has greater power"
        end

        evasion_keyword_reason(attacker, blocker, defending_player)
      end

      # Rules 702.28 (shadow), 702.31 (horsemanship), 702.36 (fear), 702.13 (intimidate),
      # 702.14 (landwalk) and "can't be blocked".
      def evasion_keyword_reason(attacker, blocker, defending_player)
        keywords = Cards::Keywords
        if attacker.has_keyword?(keywords::CANT_BE_BLOCKED)
          return "#{attacker.name} can't be blocked"
        end
        if attacker.has_keyword?(keywords::SHADOW) != blocker.has_keyword?(keywords::SHADOW)
          return "shadow creatures can block and be blocked by only shadow creatures"
        end
        if attacker.has_keyword?(keywords::HORSEMANSHIP) && !blocker.has_keyword?(keywords::HORSEMANSHIP)
          return "#{attacker.name} has horsemanship, and #{blocker.name} doesn't"
        end
        if attacker.has_keyword?(keywords::FEAR) && !(blocker.artifact? || blocker.colors.include?(:black))
          return "#{attacker.name} has fear, and #{blocker.name} is neither an artifact nor black"
        end
        if attacker.has_keyword?(keywords::INTIMIDATE) && !(blocker.artifact? || (blocker.colors & attacker.colors).any?)
          return "#{attacker.name} has intimidate, and #{blocker.name} is neither an artifact nor shares a color with it"
        end

        landwalk = attacker.keywords.grep(keywords::Landwalk).find do |keyword|
          defending_player && game.battlefield.lands.controlled_by(defending_player).any? { |land| land.type?(keyword.land_type) }
        end
        "#{attacker.name} has #{landwalk.land_type.downcase}walk" if landwalk
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

        attack.assign_damage!(assignment, pending_from_chosen_assignments(except: attack))
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

      # The damage the other attackers' chosen divisions put on each creature.
      def pending_from_chosen_assignments(except:, attacks: @attacks)
        pending = PendingDamage.new
        attacks.each do |attack|
          next if attack == except || attack.damage_assignment.nil?

          pending.add_all(attack.attacker, attack.damage_assignment)
        end
        pending
      end

      # Rule 510.1-2: work out all of the damage for this step first, then deal it together. Chosen
      # divisions go first, so the default divisions can count their damage toward lethal damage.
      def deal_damage(&deals_damage)
        pending = PendingDamage.new
        assignments = []

        attacking = @attacks.select { |attack| self.class.in_combat?(attack.attacker) && deals_damage.call(attack.attacker) }
        chosen = attacking.to_h do |attack|
          [attack, attack.chosen_damage_assignments(pending_from_chosen_assignments(except: attack, attacks: attacking))]
        end.compact
        chosen.each { |attack, division| pending.add_all(attack.attacker, division) }

        attacking.each do |attack|
          division = chosen[attack]
          unless division
            division = attack.default_damage_assignments(pending)
            pending.add_all(attack.attacker, division)
          end
          division.each { |recipient, amount| assignments << [attack.attacker, recipient, amount] }
        end

        blockers_dealing_damage = @attacks.flat_map(&:remaining_blockers).uniq.select(&deals_damage)
        blockers_dealing_damage.each do |blocker|
          next unless blocker.power.positive?

          # Rule 510.1d: a creature blocking several attackers divides its damage between them.
          attackers = attacks_blocked_by(blocker).map(&:attacker).select { |attacker| self.class.in_combat?(attacker) }
          division = self.class.divide_damage(blocker, blocker.power, attackers, pending)
          pending.add_all(blocker, division)
          division.each { |recipient, amount| assignments << [blocker, recipient, amount] }
        end

        assignments.each { |source, recipient, amount| source.fight(recipient, amount) }
      end
    end
  end
end
