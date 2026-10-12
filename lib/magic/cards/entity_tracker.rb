module Magic
  module Cards
    EntityTracker = Creature("Entity Tracker") do
      cost generic: 2, blue: 1
      creature_type "Human Scout"
      keywords :flash
      power 2
      toughness 3
    end

    class EntityTracker < Creature
      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, draw a card."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
