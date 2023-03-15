module Magic
  module Cards
    HealerOfThePride = Creature("Healer of the Pride") do
      creature_type("Cat Cleric")
      cost generic: 3, white: 1
      power 1
      toughness 1
    end

    class HealerOfThePride < Creature
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
