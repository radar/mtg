module Magic
  module Cards
    class PeerlessRecycling < Instant
      card_name "Peerless Recycling"
      cost generic: 1, green: 1
      gift :card

      def multi_target? = true

      def distinct_targets? = true

      def target_choices
        pool = controller.graveyard.permanents
        Array.new(gift_promised? ? 2 : 1) { pool }
      end

      # Return target permanent card from your graveyard to your hand. If the gift was promised,
      # instead return two target permanent cards from your graveyard to your hand.
      def resolve!(targets:)
        targets.each(&:move_to_hand!)
      end
    end
  end
end
