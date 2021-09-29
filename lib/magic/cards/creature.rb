module Magic
  module Cards
    class Creature < Card
      attr_reader :power, :toughness, :damage

      POWER = 0
      TOUGHNESS = 0

      def initialize(**args)
        @power = self.class::POWER
        @toughness = self.class::TOUGHNESS
        @damage = 0
        super(**args)
      end

      def alive?
        (toughness - damage).positive?
      end

      def dead?
        !alive?
      end

      def take_damage(damage_dealt)
        @damage += damage_dealt

        destroy! if dead?
      end
    end
  end
end
