module Magic
  module Cards
    class Creature < Card
      POWER = 0
      TOUGHNESS = 0

      def base_power = prototyped ? self.class::PROTOTYPE[:power] : self.class::POWER

      def base_toughness = prototyped ? self.class::PROTOTYPE[:toughness] : self.class::TOUGHNESS
    end
  end
end
