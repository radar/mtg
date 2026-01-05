module Magic
  module Cards
    LibraryLarcenist = Creature("Library Larcenist") do
      creature_type "Merfolk Rogue"
      cost generic: 2, blue: 1
      power 1
      toughness 2

      class CreatureAttackedTrigger < TriggeredAbility
        def should_perform?
          this?
        end

        def call
          actor.controller.draw!
        end
      end

      def event_handlers
        {
          Events::CreatureAttacked => CreatureAttackedTrigger
        }
      end
    end
  end
end
