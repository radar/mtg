module Magic
  module Cards
    ParanormalAnalyst = Creature("Paranormal Analyst") do
      cost generic: 1, blue: 1
      creature_type "Human Detective"
      power 1
      toughness 3
    end

    class ParanormalAnalyst < Creature
      # "Whenever you manifest dread, put a card you put into your graveyard this way into your hand."
      class ManifestedDreadTrigger < TriggeredAbility
        def should_perform?
          event.player == controller && event.graveyard_card&.zone&.graveyard?
        end

        def call
          event.graveyard_card.move_to_hand!
        end
      end

      def event_handlers = { Events::ManifestedDread => ManifestedDreadTrigger }
    end
  end
end
