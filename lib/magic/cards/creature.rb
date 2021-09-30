module Magic
  module Cards
    class Creature < Card
      attr_reader :damage, :power_modifiers, :toughness_modifiers

      POWER = 0
      TOUGHNESS = 0

      def initialize(**args)
        @base_power = self.class::POWER
        @base_toughness = self.class::TOUGHNESS
        @power_modifiers = []
        @toughness_modifiers = []

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
        @base_power + @power_modifiers.sum(&:power)
      end

      def toughness
        @base_toughness + @toughness_modifiers.sum(&:toughness)
      end

      def deathtouch?
        keywords.include?(Keywords::DEATHTOUCH)
      end

      def first_strike?
        keywords.include?(Keywords::DOUBLE_STRIKE)
      end

      def double_strike?
        keywords.include?(Keywords::DOUBLE_STRIKE)
      end

      def fight(creature)
        creature.take_damage(power)
        creature.mark_for_death! if deathtouch?
      end

      def mark_for_death!
        @marked_for_death = true
      end

      def take_damage(damage_dealt)
        @damage += damage_dealt

        destroy! if dead?
      end

      def left_the_battlefield!
        @power_modifiers.clear
        @toughness_modifiers.clear

        super
      end
    end
  end
end
