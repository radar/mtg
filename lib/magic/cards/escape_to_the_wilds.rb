module Magic
  module Cards
    class EscapeToTheWilds < Sorcery
      card_name "Escape to the Wilds"
      cost generic: 3, red: 1, green: 1

      # "Exile the top five cards of your library. You may play cards exiled this way until the end of your next turn.
      # You may play an additional land this turn."
      def resolve!
        player = controller
        player.library.first(5).each do |card|
          trigger_effect(:exile, target: card)
          game.play_permissions.grant_until_end_of_next_turn(card:, player:)
        end
        player.grant_additional_land_this_turn!
      end
    end
  end
end
