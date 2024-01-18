module Magic
  module Choice
    class Effect
      attr_reader :player
      def initialize(player)
        @player = player
      end
    end
  end
end
