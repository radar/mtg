module Magic
  module Cards
    PeerPastTheVeil = Instant("Peer Past The Veil") do
      cost generic: 2, red: 1, green: 1
    end

    class PeerPastTheVeil < Instant
      # "Discard your hand. Then draw X cards, where X is the number of card types among cards in your graveyard."
      def resolve!
        # A resolving spell is still in its zone (the hand) until `Actions::Cast` moves it, so skip it.
        [*controller.hand.cards].reject { _1 == self }.each(&:discard!)
        draw_cards(controller.graveyard.card_type_count)
      end
    end
  end
end
