module Magic
  module Events
    class CardEnteredZoneTransition
      def self.new(card, from:, to:)
        Events::CardEnteredZone.new(card, from: from, to: to)
      end
    end
  end
end
