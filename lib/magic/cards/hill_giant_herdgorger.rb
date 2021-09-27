module Magic
  module Cards
    class HillGiantHerdgorger < Creature
      def initialize(**args)
        super(
          name: "Hill Giant Herdgorger",
          cost: { green: 2, any: 4 },
          **args
        )
      end

      def add_to_battlefield!
        controller.gain_life(3)
        super
      end
    end
  end
end
