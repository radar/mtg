module Magic
  module Cards
    class Creature < Card
      attr_reader :damage

      POWER = 0
      TOUGHNESS = 0

      def initialize(**args)
        @base_power = self.class::POWER
        @base_toughness = self.class::TOUGHNESS
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
        modify_power_abilities = game.battlefield.static_abilities
          .select { |ability| ability.applies_to?(self) }
          .select(&:modifies_power?)

        @base_power + modify_power_abilities.sum(&:power)
      end

      def toughness
        modify_power_abilities = game.battlefield.static_abilities
        .select { |ability| ability.applies_to?(self) }
        .select(&:modifies_power?)

        @base_power + modify_power_abilities.sum(&:power)
      end

      def take_damage(damage_dealt)
        @damage += damage_dealt

        destroy! if dead?
      end
    end
  end
end
