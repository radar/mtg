module Magic
  module Events
    class BeginningOfEndStep
      attr_reader :active_player

      def initialize(active_player:)
        @active_player = active_player
      end

      def inspect
        "#<Events::BeginningOfEndStep player:#{active_player}>"
      end
    end
  end
end
