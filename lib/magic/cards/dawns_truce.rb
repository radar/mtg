module Magic
  module Cards
    class DawnsTruce < Instant
      card_name "Dawn's Truce"
      cost generic: 1, white: 1
      gift :card

      # You and permanents you control gain hexproof until end of turn. If the gift was promised,
      # permanents you control also gain indestructible until end of turn.
      def resolve!
        controller.gain_hexproof_until_end_of_turn!
        battlefield.controlled_by(controller).each do |permanent|
          trigger_effect(:grant_keyword, target: permanent, keyword: :hexproof)
          trigger_effect(:grant_keyword, target: permanent, keyword: :indestructible) if gift_promised?
        end
      end
    end
  end
end
