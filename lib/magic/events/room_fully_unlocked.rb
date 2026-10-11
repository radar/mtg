module Magic
  module Events
    # The second door of a Room was unlocked: "whenever you fully unlock a Room" (Eerie). Not fired for a Room that
    # entered, since only unlocking a door can fully unlock it.
    class RoomFullyUnlocked < Base
      attr_reader :permanent, :player

      def initialize(permanent:, player: permanent.controller)
        @permanent = permanent
        @player = player
      end

      def inspect
        "#<Events::RoomFullyUnlocked permanent: #{permanent.name}>"
      end
    end
  end
end
