module Magic
  module Events
    class PermanentEnteredZoneTransition
      def self.new(permanent, from:, to:)
        if to.battlefield?
          Events::EnteredTheBattlefield.new(permanent)
        else
          Events::PermanentEnteredZone.new(permanent, from: from, to: to)
        end
      end
    end
  end
end
