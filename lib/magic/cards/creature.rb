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
        (toughness - damage) > 0
      end

      def dead?
        !alive?
      end
    end
  end
end
