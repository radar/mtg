module Magic
  # Recruit: "Draw a card, then discard a card. If you discarded a nonland card, create a 1/1 white Human Soldier
  # creature token." `Recruit.call(player:)` draws, then queues the discard choice (answer with `card:`).
  module Recruit
    class DiscardChoice < Magic::Choice::Discard
      def resolve!(card: nil, cards: nil)
        chosen = cards || [card]
        super
        return if chosen.all?(&:land?)

        Tokens::HumanSoldier.new(game: player.game, owner: player).resolve!
      end
    end

    def self.call(player:)
      player.draw!
      player.game.add_choice(DiscardChoice.new(player: player)) if player.hand.any?
    end
  end
end
