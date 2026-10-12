module Magic
  module Events
    # A door of a Room was unlocked (also when a Room enters with the door it was cast as). `player` is the Room's
    # controller, "you" in "when you unlock this door".
    class DoorUnlocked < Base
      attr_reader :permanent, :door, :player

      def initialize(permanent:, door:, player: permanent.controller)
        @permanent = permanent
        @door = door
        @player = player
      end

      def inspect
        "#<Events::DoorUnlocked permanent: #{permanent.name}, door: #{door.name}>"
      end
    end
  end
end
