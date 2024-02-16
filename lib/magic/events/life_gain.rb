module Magic
  module Events
    class LifeGain < Base
      attr_reader :player, :life

      def initialize(player:, life:)
        @player = player
        @life = life
        super()
      end

      def inspect
        "#<Events::LifeGain player: #{player.name}, life: #{life}>"
      end
    end
  end
end
