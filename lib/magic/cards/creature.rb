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
        super(**args)
      end

      def alive?
        (toughness - damage).positive?
      end

      def dead?
        !alive?
      end

      def power
        @base_power + @power_modifiers.sum(&:power)
      end

      def toughness
        @base_toughness + @toughness_modifiers.sum(&:toughness)
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
