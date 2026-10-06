module Magic
  module Cards
    CuriosityCrafter = Creature("Curiosity Crafter") do
      cost generic: 3, blue: 1
      creature_type "Bird Wizard"
      keywords :flying
      power 3
      toughness 3
    end

    class CuriosityCrafter < Creature
      # "You have no maximum hand size." (`Player#maximum_hand_size` asks the permanents.)
      def no_maximum_hand_size? = true

      # "Whenever a creature token you control deals combat damage to a player, draw a card."
      class TokenDamageTrigger < TriggeredAbility
        def should_perform?
          event.combat? && event.target.player? && event.source.respond_to?(:token?) && event.source.token? &&
            event.source.controller == controller
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = { Events::DamageDealt => TokenDamageTrigger }
    end
  end
end
