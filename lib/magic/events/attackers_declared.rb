module Magic
  module Events
    class AttackersDeclared
      attr_reader :active_player

      def initialize(active_player:)
        @active_player = active_player
      end

      def inspect
        "#<Events::AttackersDeclared>"
      end
    end
  end
end
