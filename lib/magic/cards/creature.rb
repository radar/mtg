module Magic
  module Cards
    class Creature < Card
      attr_reader :power, :toughness

      def initialize(power: 0, toughness: 0, **args)
        @power = power
        @toughness = toughness
        super(**args)
      end

      def creature?
        true
      end
    end
  end
end
