module Magic
  module Events
    class Scry
      attr_reader :player, :top, :bottom

      def initialize(player:, top:, bottom:)
        @player = player
        @top = top
        @bottom = bottom
      end

      def inspect
        "#<Events::Scry player: #{player}, top: #{top}, bottom: #{bottom}>"
      end
    end
  end
end
