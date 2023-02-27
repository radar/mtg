module Magic
  module Cards
    LibraryLarcenist = Creature("Library Larcenist") do
      creature_type "Merfolk Rogue"
      cost generic: 2, blue: 1
      power 1
      toughness 2

      def event_handlers
        {
          Events::CreatureAttacked => -> (receiver, event) do
            return if event.attacker != receiver

            receiver.controller.draw!
          end
        }
      end
    end
  end
end
