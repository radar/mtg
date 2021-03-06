module Magic
  module Cards
    class Creature < Card
      attr_reader :damage, :modifiers, :counters

      class Buff
        attr_reader :power, :toughness, :until_eot

        def initialize(power: 0, toughness: 0, until_eot: true)
          @power = power
          @toughness = toughness
          @until_eot = until_eot
        end

        def until_eot?
          @until_eot
        end
      end

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

      def alive?
        (toughness - damage).positive?
      end

      def dead?
        @marked_for_death || !alive?
      end

      def power
        @base_power +
          @modifiers.sum(&:power) +
          @counters.sum(&:power) +
          @attachments.sum(&:power_buff) +
          static_ability_buffs.sum(&:power)
      end

      def toughness
        @base_toughness +
          @modifiers.sum(&:toughness) +
          @counters.sum(&:toughness) +
          @attachments.sum(&:toughness_buff) +
          static_ability_buffs.sum(&:toughness)
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

      def add_counter(counter_type, amount: 1)
        amount.times do
          @counters << counter_type.new
        end
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

      private

      def static_ability_buffs
        battlefield.static_abilities.of_type(Abilities::Static::CreaturesGetBuffed).applies_to(self)
      end
    end
  end
end
