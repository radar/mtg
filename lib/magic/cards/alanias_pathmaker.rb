module Magic
  module Cards
    AlaniasPathmaker = Creature("Alania's Pathmaker") do
      cost generic: 3, red: 1
      creature_type("Otter Wizard")
      power 4
      toughness 2
    end

    class AlaniasPathmaker < Creature
      # When this creature enters, exile the top card of your library. Until the end of your next turn, you
      # may play that card.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          top = controller.library.first or return

          trigger_effect(:exile, target: top)
          game.play_permissions.grant_until_end_of_next_turn(card: top, player: controller)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
