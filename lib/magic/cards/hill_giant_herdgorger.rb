module Magic
  module Cards
    HillGiantHerdgorger = Creature("Hill Giant Herdgorger") do
      type "Creature -- Giant"
      cost green: 2, any: 4
      power 7
      toughness 6
    end

    class HillGiantHerdgorger < Creature
      def entered_the_battlefield!
        controller.gain_life(3)
      end
    end
  end
end
