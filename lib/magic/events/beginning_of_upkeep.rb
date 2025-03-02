module Magic
  module Events
    class BeginningOfUpkeep
      attr_reader :player

      def initialize(player:)
        @player = player
      end

      def inspect
        "#<Events::BeginningOfUpkeep player=#{player}>"
      end
    end
  end
end
