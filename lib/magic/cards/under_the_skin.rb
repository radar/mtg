module Magic
  module Cards
    class UnderTheSkin < Sorcery
      card_name "Under the Skin"
      cost generic: 2, green: 1

      # Manifests dread, then (once the face-down creature is there, or there was nothing to manifest) offers the return.
      class ManifestChoice < Magic::Choice::ManifestDread
        def manifested(_permanent) = offer_return
        def nothing_to_manifest = offer_return

        private

        def offer_return
          choice = Magic::Choice::ReturnFromAmong.new(actor: actor, cards: player.graveyard.cards.to_a, filter: ->(card) { card.permanent? })
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "Manifest dread. You may return a permanent card from your graveyard to your hand."
      def resolve!
        ManifestChoice.perform(actor: self)
      end
    end
  end
end
