module Magic
  module Cards
    Duress = Sorcery("Duress") do
      cost black: 1
    end

    class Duress < Sorcery
      def target_choices
        game.opponents(controller)
      end

      def resolve!(target:)
        game.notify!(Events::CardsRevealed.new(player: target, cards: target.hand.cards.to_a))
        choice = Magic::Choice::DiscardFromRevealedHand.new(actor: self, player: target, excluded_types: ["Creature", "Land"])
        game.add_choice(choice) if choice.choices.any?
      end
    end
  end
end
