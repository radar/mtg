module Magic
  class Game
    class CombatPhase
      class AttackerHasProtection < StandardError; end
      class IllegalBlock < StandardError; end
      class InvalidDamageAssignment < StandardError; end

      class Attack
        attr_reader :attacker, :target, :blockers

        def initialize(attacker:, target:)
          @attacker = attacker
          @target = target
          @blockers = []
          @blocked = false
          @assignment = nil
        end

        def retarget(new_target)
          @target = new_target
        end

        def declare_blocker(blocker)
          @blocked = true
          @blockers << blocker
        end

        # Rule 509.1h: once blocked, an attacker stays blocked even if every blocker leaves combat.
        def blocked?
          @blocked
        end

        # Blockers still in a position to be dealt damage (and to deal it).
        def active_blockers
          blockers.reject(&:dead?)
        end

        # The attacking player's chosen split of combat damage among the blockers (a Hash of
        # blocker => damage), or nil to use the default lethal-first assignment.
        attr_reader :assignment

        def assign_damage(assignment)
          validate_assignment!(assignment)
          @assignment = assignment
        end

        def clear_assignment!
          @assignment = nil
        end

        # Rule 510.1: the [recipient, damage] pairs for the attacker's combat damage: each
        # blocker's share, plus what's left over for the attacked player/planeswalker
        # (trample). Blockers assign their damage to the attacker separately (see
        # CombatPhase#damage_events).
        def attacker_damage
          power = attacker.power
          return [] if power <= 0

          if !blocked?
            [[target, power]]
          elsif active_blockers.empty?
            attacker.trample? ? [[target, power]] : []
          else
            split = assignment || default_assignment(power)
            events = split.to_a
            leftover = power - split.values.sum
            events << [target, leftover] if attacker.trample? && leftover.positive?
            events
          end
        end

        # Damage that is lethal to +blocker+ from this attacker (rule 702.2c: any damage from a
        # deathtouch source is lethal).
        def lethal_damage_for(blocker)
          return 1 if attacker.deathtouch?

          [blocker.toughness - blocker.damage, 0].max
        end

        private

        # Lethal damage to each blocker in turn; whatever is left goes to the last blocker
        # (or, with trample, past all of them to the attacked player).
        def default_assignment(power)
          remaining = power
          blockers = active_blockers
          blockers.each_with_index.to_h do |blocker, index|
            amount = [lethal_damage_for(blocker), remaining].min
            amount = remaining if index == blockers.size - 1 && !attacker.trample?
            remaining -= amount
            [blocker, amount]
          end
        end

        def validate_assignment!(assignment)
          unless assignment.keys.sort_by(&:object_id) == active_blockers.sort_by(&:object_id)
            raise InvalidDamageAssignment, "damage must be assigned among the blockers only"
          end
          raise InvalidDamageAssignment, "cannot assign negative damage" if assignment.values.any?(&:negative?)

          total = assignment.values.sum
          power = attacker.power
          raise InvalidDamageAssignment, "cannot assign more than #{power} damage" if total > power

          if attacker.trample?
            # Rule 702.19b: a trampler must assign lethal damage to every blocker before the player.
            if total < power && assignment.any? { |blocker, damage| damage < lethal_damage_for(blocker) }
              raise InvalidDamageAssignment, "must assign lethal damage to every blocker before trampling over"
            end
          elsif total < power
            raise InvalidDamageAssignment, "all combat damage must be assigned"
          end
        end
      end

      attr_reader :game, :attacks

      def initialize(game:)
        @game = game
        @attacks = []
        @dealt_first_strike_damage = []
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
        block_illegal_reason(attacker: attacker, blocker: blocker).nil?
      end

      # Why +blocker+ can't block +attacker+ (rules 509.1a-b, 702), or nil if it can.
      # Menace-style "at least N blockers" constraints depend on the whole declaration
      # and are checked by #validate_blocks! once blockers are finalised.
      def block_illegal_reason(attacker:, blocker:)
        attack = attack_for_attacker(attacker)
        defender = defending_player(attack)

        return "#{attacker.name} has protection from #{blocker.name}" if attacker.protected_from?(blocker)
        return "#{blocker.name} is not a creature" unless blocker.creature?
        return "#{blocker.name} is tapped" if blocker.tapped?
        return "#{blocker.name} is not controlled by the defending player" if defender && blocker.controller != defender
        return "#{blocker.name} is already blocking" if @attacks.any? { |other| other.blockers.include?(blocker) }
        return "#{blocker.name} can't block" unless blocker.can_block?(attacker)

        evasion_reason(attacker, blocker, defender)
      end

      def declare_blocker(blocker, attacker:)
        raise AttackerHasProtection if attacker.protected_from?(blocker)

        reason = block_illegal_reason(attacker: attacker, blocker: blocker)
        raise IllegalBlock, reason if reason

        attack = @attacks.find do |attack|
          attack.attacker == attacker
        end
        attack.declare_blocker(blocker)
        game.notify!(Events::CreatureBlocked.new(attacker: attacker, blocker: blocker))
      end

      # Rule 509.1b / 702.110b: checks blocks that are only illegal as a whole (menace).
      # Called once blockers are final, before combat damage.
      def validate_blocks!
        @attacks.each do |attack|
          next unless attack.attacker.has_keyword?(Cards::Keywords::MENACE)
          next unless attack.blockers.size == 1

          raise IllegalBlock, "#{attack.attacker.name} has menace and can't be blocked except by two or more creatures"
        end
      end

      # The attacking player's damage split for +attacker+ (a Hash of blocker => damage).
      def assign_combat_damage(attacker, assignment)
        attack_for_attacker(attacker).assign_damage(assignment)
      end

      # Rule 510.4: creatures with first strike or double strike deal damage in the first step.
      def deal_first_strike_damage
        strikers = combatants.select { |creature| creature.first_strike? || creature.double_strike? }
        @dealt_first_strike_damage = strikers
        deal_damage(strikers)
      end

      # Every other creature, plus double strikers again, deals damage in the regular step.
      # Creatures that already dealt first-strike damage (and lack double strike) don't.
      def deal_combat_damage
        regular = combatants.reject do |creature|
          @dealt_first_strike_damage.include?(creature) && !creature.double_strike?
        end
        deal_damage(regular)
        @dealt_first_strike_damage = []
        @attacks.each(&:clear_assignment!)
      end

      private

      def defending_player(attack)
        target = attack&.target
        return unless target
        return target if target.player?

        target.controller if target.respond_to?(:controller)
      end

      def evasion_reason(attacker, blocker, defender)
        keywords = Cards::Keywords
        if attacker.has_keyword?(keywords::CANT_BE_BLOCKED)
          return "#{attacker.name} can't be blocked"
        end
        if attacker.flying? && !(blocker.flying? || blocker.reach?)
          return "#{attacker.name} has flying and #{blocker.name} has neither flying nor reach"
        end
        if attacker.has_keyword?(keywords::SHADOW) != blocker.has_keyword?(keywords::SHADOW)
          return "shadow creatures can block and be blocked by only shadow creatures"
        end
        if attacker.has_keyword?(keywords::HORSEMANSHIP) && !blocker.has_keyword?(keywords::HORSEMANSHIP)
          return "#{attacker.name} has horsemanship"
        end
        if attacker.has_keyword?(keywords::FEAR) && !(blocker.artifact? || blocker.colors.include?(:black))
          return "#{attacker.name} has fear and #{blocker.name} is neither an artifact nor black"
        end
        if attacker.has_keyword?(keywords::INTIMIDATE) && !(blocker.artifact? || (blocker.colors & attacker.colors).any?)
          return "#{attacker.name} has intimidate and #{blocker.name} is neither an artifact nor shares a color with it"
        end
        if attacker.has_keyword?(keywords::SKULK) && blocker.power > attacker.power
          return "#{attacker.name} has skulk and #{blocker.name} has greater power"
        end

        landwalk = attacker.keywords.grep(keywords::Landwalk).find do |keyword|
          defender && game.battlefield.lands.controlled_by(defender).any? { |land| land.type?(keyword.land_type) }
        end
        "#{attacker.name} has #{landwalk.land_type.downcase}walk" if landwalk
      end

      # Creatures that may deal combat damage right now: attackers still in play and blockers
      # of attacks that are still in play.
      def combatants
        @attacks.flat_map do |attack|
          next [] if attack.attacker.dead?

          [attack.attacker, *attack.active_blockers]
        end
      end

      # Rule 510.2: all combat damage in a step is dealt simultaneously, so every assignment
      # is worked out first (a creature that dies mid-step still dealt its damage).
      def deal_damage(dealers)
        damage_events(dealers).each do |source, target, amount|
          source.fight(target, amount)
        end
      end

      def damage_events(dealers)
        @attacks.flat_map do |attack|
          next [] if attack.attacker.dead?

          events = []
          if dealers.include?(attack.attacker)
            events.concat(attack.attacker_damage.map { |target, amount| [attack.attacker, target, amount] })
          end
          attack.active_blockers.each do |blocker|
            next unless dealers.include?(blocker)

            events << [blocker, attack.attacker, blocker.power]
          end
          events.select { |_, _, amount| amount.positive? }
        end
      end
    end
  end
end
