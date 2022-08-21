module Magic
  module Cards
    class Creature < Card
      attr_reader :base_power, :base_toughness

      POWER = 0
      TOUGHNESS = 0

      def initialize(**args)
        @base_power = self.class::POWER
        @base_toughness = self.class::TOUGHNESS
        super(**args)
      end
    end
  end
end
