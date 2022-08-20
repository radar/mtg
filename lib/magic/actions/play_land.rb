module Magic
  module Actions
    class PlayLand < Action
      attr_reader :card

      def initialize(card:, **args)
        @card = card
        super(**args)
      end

      def inspect
        "#<Actions::PlayLand name: #{card.name}, player: #{player.inspect}>"
      end

      def perform
        card.resolve!(player)
      end
    end
  end
end
