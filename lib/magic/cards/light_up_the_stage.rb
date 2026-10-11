module Magic
  module Cards
    class LightUpTheStage < Sorcery
      card_name "Light Up the Stage"
      cost generic: 2, red: 1
      spectacle red: 1

      # "Exile the top two cards of your library. Until the end of your next turn, you may play those cards."
      def resolve!
        controller.library.cards.first(2).each do |card|
          card.exile!
          game.play_permissions.grant_until_end_of_next_turn(card: card, player: controller)
        end
      end
    end
  end
end
