module Magic
  module Cards
    GundabadOpportunist = Creature("Gundabad Opportunist") do
      cost generic: 3, red: 1
      creature_type "Goblin Rogue"
      power 4
      toughness 2

      # "When this creature enters, exile the top card of your library. Until the end of your next turn,
      # you may play that card."
      enters_the_battlefield do
        top = controller.library.first
        if top
          top.exile!
          game.play_permissions.grant_until_end_of_next_turn(card: top, player: controller)
        end
      end
    end
  end
end
