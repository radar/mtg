module Magic
  module Cards
    class BadDeal < Sorcery
      card_name "Bad Deal"
      cost generic: 4, black: 2

      # "You draw two cards and each opponent discards two cards. Each player loses 2 life."
      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 2)
        game.opponents(controller).each do |opponent|
          game.add_choice(Magic::Choice::Discard.new(player: opponent, amount: 2)) if opponent.hand.any?
        end
        game.players.each { |player| trigger_effect(:lose_life, target: player, life: 2) }
      end
    end
  end
end
