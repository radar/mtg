module Magic
  module Cards
    class KulrathZealot < Creature
      card_name "Kulrath Zealot"
      cost generic: 5, red: 1
      creature_type "Elemental Warrior"
      power 6
      toughness 5
      landcycling({ generic: 1, red: 1 })

      # "When this creature enters, exile the top card of your library. Until the end of your next
      # turn, you may play that card."
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
