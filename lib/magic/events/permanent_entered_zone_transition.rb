module Magic
  module Events
    class PermanentEnteredZoneTransition
      def self.new(permanent, from:, to:)
        events = []

        if to.battlefield?
          events << Events::EnteredTheBattlefield.new(permanent)
          events << Events::Landfall.new(permanent) if permanent.land?
        else
          events << Events::PermanentEnteredZone.new(permanent, from: from, to: to)
        end

        events
      end
    end
  end
end
