module Magic
  module Cards
    EmberheartChallenger = Creature("Emberheart Challenger") do
      cost generic: 1, red: 1
      creature_type("Mouse Warrior")
      keywords :haste, :prowess
      power 2
      toughness 2
    end

    class EmberheartChallenger < Creature
      # Valiant -- exile the top card of your library. Until end of turn, you may play that card.
      class ValiantTrigger < TriggeredAbility::Valiant
        def call
          top = controller.library.first or return

          trigger_effect(:exile, target: top)
          game.play_permissions.grant_until_end_of_turn(card: top, player: controller)
        end
      end

      def event_handlers = super.merge(ValiantTrigger.handlers)
    end
  end
end
