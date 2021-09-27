module Magic
  module Cards
    class HillGiantHerdgorger < Creature
      NAME = "Hill Giant Herdgorger"
      TYPE_LINE = "Creature -- Giant"
      COST = { green: 2, any: 4 }

      def entered_the_battlefield!
        controller.gain_life(3)
        super
      end
    end
  end
end
