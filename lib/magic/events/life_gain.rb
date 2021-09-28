module Magic
  module Events
    class LifeGain
      attr_reader :player, :life

      def initialize(player:, life:)
        @player = player
        @life = life
      end

      def inspect
        "#<Events::LifeGain player: #{player.name}, life: #{life}>"
      end
    end
  end
end
