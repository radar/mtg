module Magic
  module Cards
    TheTormentOfGollum = Sorcery("The Torment of Gollum") do
      cost generic: 3, black: 1
    end

    class TheTormentOfGollum < Sorcery
      # "You choose a nonland card from it." Mandatory; skipping discards the first legal card.
      class DiscardChoice < Magic::Choice::DiscardFromRevealedHand
        def decline!
          resolve!(card: choices.first) if choices.any?
        end
      end

      def target_choices
        game.opponents(controller)
      end

      # "Target opponent reveals their hand. You choose a nonland card from it. That player discards that card.
      # Amass Orcs 2."
      def resolve!(target:)
        game.notify!(Events::CardsRevealed.new(player: target, cards: target.hand.cards.to_a))
        choice = DiscardChoice.new(actor: self, player: target, excluded_types: ["Land"])
        game.add_choice(choice) if choice.choices.any?
        Magic::Amass.call(source: self, controller: controller, amount: 2, subtype: "Orc")
        super()
      end
    end
  end
end
