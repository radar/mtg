module Magic
  module Events
    class PermanentLeavingZoneTransition
      def self.new(permanent, from:, to:)
        events = []
        if (from && from.battlefield?) && to.graveyard? && permanent.creature?
          events << Events::CreatureDied.new(permanent)
        end

        if from
          events << Events::PermanentLeavingZone.new(permanent, from: from, to: to)
        end
        events
      end
    end
  end
end
