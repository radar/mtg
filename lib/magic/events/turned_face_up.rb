module Magic
  module Events
    # A face-down permanent was turned face up (`permanent.card` is now what it is).
    class TurnedFaceUp < Base
      attr_reader :permanent, :player

      def initialize(permanent:, player: permanent.controller)
        @permanent = permanent
        @player = player
      end

      def inspect
        "#<Events::TurnedFaceUp permanent: #{permanent.name}>"
      end
    end
  end
end
