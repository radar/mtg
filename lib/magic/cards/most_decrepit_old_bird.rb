module Magic
  module Cards
    MostDecrepitOldBird = Creature("Most Decrepit Old Bird") do
      cost blue: 1
      creature_type "Bird"
      power 1
      toughness 1
      keywords :flying
    end

    class MostDecrepitOldBird < Creature
      # Speak Secrets {1}{U}, Sorcery -- Adventure:
      # "Mill four cards, then put an instant or sorcery card from among them into your hand."
      adventure generic: 1, blue: 1

      def adventure_resolve!(**)
        milled = controller.mill(4)
        choice = Choice::ReturnFromAmong.new(actor: self, cards: milled, filter: ->(card) { card.instant? || card.sorcery? })
        game.add_choice(choice) if choice.choices.any?
      end

      # "Threshold -- This creature gets +1/+1 as long as there are seven or more cards in your graveyard."
      class Threshold < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        conditions { source.controller.graveyard.cards.count >= 7 }
        applicable_targets { [source] }
      end

      def static_abilities = [Threshold]
    end
  end
end
