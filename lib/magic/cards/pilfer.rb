module Magic
  module Cards
    Pilfer = Sorcery("Pilfer") do
      cost generic: 1, black: 1
    end

    class Pilfer < Sorcery
      def target_choices
        game.opponents(controller)
      end

      def resolve!(target:)
        game.notify!(Events::CardsRevealed.new(player: target, cards: target.hand.cards.to_a))
        choice = Magic::Choice::DiscardFromRevealedHand.new(actor: self, player: target, excluded_types: ["Land"])
        game.add_choice(choice) if choice.choices.any?
      end
    end
  end
end
