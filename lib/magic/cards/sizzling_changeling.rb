module Magic
  module Cards
    class SizzlingChangeling < Creature
      card_name "Sizzling Changeling"
      cost generic: 2, red: 1
      creature_type "Shapeshifter"
      power 3
      toughness 2
      keywords :changeling

      # "When this creature dies, exile the top card of your library. Until the end of your next
      # turn, you may play that card."
      class DiesTrigger < TriggeredAbility::Death
        def call
          top = controller.library.first or return

          trigger_effect(:exile, target: top)
          game.play_permissions.grant_until_end_of_next_turn(card: top, player: controller)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
