module Magic
  module Events
    class LifeLoss
      attr_reader :player, :life

      def initialize(player:, life:)
        @player = player
        @life = life
      end

      def inspect
        "#<Events::LifeLoss player: #{player.name}, life: #{life}>"
      end
    end
  end
end
