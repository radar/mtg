module Magic
  module Events
    class EnteredZoneTransition
      def self.new(card, from:, to:)
        if to.battlefield?
          Events::EnteredTheBattlefield.new(card)
        else
          Events::EnteredZone.new(card, from: from, to: to)
        end
      end
    end
  end
end
