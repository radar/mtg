module Magic
  module Cards
    class Creature < Card
      attr_reader :damage, :modifiers, :counters, :base_power, :base_toughness

      POWER = 0
      TOUGHNESS = 0

      def initialize(**args)
        @base_power = self.class::POWER
        @base_toughness = self.class::TOUGHNESS
        @modifiers = []
        @damage = 0
        @marked_for_death = false
        super(**args)
      end

      def inspect
        "#<Magic::Permanent name:#{card.name} controller:#{controller.name}>"
      end
      alias_method :to_s, :inspect

      def alive?
        (toughness - damage).positive?
      end

      def dead?
        @marked_for_death || !alive?
      end

      def can_attack?
        @attachments.all?(&:can_attack?)
      end

      def can_block?
        @attachments.all?(&:can_block?)
      end

      def fight(target, assigned_damage = power)
        game.notify!(
          Events::DamageDealt.new(source: self, target: target, damage: assigned_damage)
        )
        controller.gain_life(assigned_damage) if lifelink?
        if target.is_a?(Creature)
          target.mark_for_death! if deathtouch? || target.dead?
        end
      end

      def mark_for_death!
        @marked_for_death = true
      end

      def take_damage(damage_dealt)
        @damage += damage_dealt
      end

      def left_the_battlefield!
        @modifiers.clear
        @attachments.each(&:destroy!)
        @attachments.clear

        super
      end

      def whenever_this_attacks
      end

      def cleanup!
        until_eot_modifiers = modifiers.select(&:until_eot?)
        until_eot_modifiers.each { |modifier| modifiers.delete(modifier) }

        super
      end
    end
  end
end
