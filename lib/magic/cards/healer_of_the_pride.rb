module Magic
  module Cards
    class HealerOfThePride < Creature
      NAME = "Healer of the Pride"
      COST = { any: 3, white: 1 }
      TYPE_LINE = creature_type("Cat Cleric")

      def event_handlers
        {
          Events::EnteredTheBattlefield => -> (receiver, event) do
            controller = receiver.controller
            return unless event.permanent.controller?(controller)

            controller.gain_life(2)
          end
        }
      end
    end
  end
end
