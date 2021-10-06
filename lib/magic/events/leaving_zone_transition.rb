module Magic
  module Events
    class LeavingZoneTransition
      def self.new(card, from:, to:)
        Events::LeavingZone.new(card, from: from, to: to)
      end
    end
  end
end
