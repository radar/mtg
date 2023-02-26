module Magic
  module Events
    class PermanentLeavingZoneTransition
      def self.new(permanent, from:, to:)
        if (from && from.battlefield?) && to.graveyard?
          Events::PermanentWillDie.new(permanent)
        else
          Events::PermanentLeavingZone.new(permanent, from: from, to: to)
        end
      end
    end
  end
end
