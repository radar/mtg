module Magic
  module Cards
    class InsideInformation < Sorcery
      card_name "Inside Information"
      cost x: 1, black: 2

      def target_choices = game.opponents(controller)

      # "Exile the top X cards of target opponent's library. You may play those cards this turn. If you cast a
      # spell this way, pay life equal to its mana value rather than pay its mana cost."
      def resolve!(target:, value_for_x: 0)
        target.library.cards.first(value_for_x.to_i).each do |card|
          card.exile!
          game.play_permissions.grant_until_end_of_turn_paying_life(card: card, player: controller)
        end
      end
    end
  end
end
