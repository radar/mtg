module Magic
  module Cards
    class Creature < Card
      attr_reader :damage, :power_modifiers, :toughness_modifiers

      class Counter
        attr_reader :power, :toughness

        def initialize(power:, toughness:)
          @power = power
          @toughness = toughness
        end
      end

      POWER = 0
      TOUGHNESS = 0

      def initialize(**args)
        @base_power = self.class::POWER
        @base_toughness = self.class::TOUGHNESS
        @power_modifiers = []
        @toughness_modifiers = []
        @counters = []

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
        @base_power + @power_modifiers.sum(&:power) + @counters.sum(&:power)
      end

      def toughness
        @base_toughness + @toughness_modifiers.sum(&:toughness) + @counters.sum(&:toughness)
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

      def add_counter(power:, toughness:)
        @counters << Counter.new(power: power, toughness: toughness)
      end

      def left_the_battlefield!
        @power_modifiers.clear
        @toughness_modifiers.clear

        super
      end
    end
  end
end
