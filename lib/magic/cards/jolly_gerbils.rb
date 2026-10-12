module Magic
  module Cards
    JollyGerbils = Creature("Jolly Gerbils") do
      cost generic: 1, white: 1
      creature_type("Hamster Citizen")
      power 2
      toughness 3
    end

    class JollyGerbils < Creature
      # Whenever you give a gift, draw a card.
      class GiftTrigger < TriggeredAbility
        def should_perform? = event.player == controller

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers = super.merge(Events::GiftGiven => GiftTrigger)
    end
  end
end
