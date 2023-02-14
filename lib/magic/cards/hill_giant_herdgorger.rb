module Magic
  module Cards
    HillGiantHerdgorger = Creature("Hill Giant Herdgorger") do
      creature_type("Giant")
      cost green: 2, any: 4
      power 7
      toughness 6
    end

    class HillGiantHerdgorger < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          controller.gain_life(3)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
