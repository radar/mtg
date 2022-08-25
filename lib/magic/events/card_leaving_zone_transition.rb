module Magic
  module Events
    class CardLeavingZoneTransition
      def self.new(card, from:, to:)
        Events::CardLeavingZone.new(card, from: from, to: to)
      end
    end
  end
end
