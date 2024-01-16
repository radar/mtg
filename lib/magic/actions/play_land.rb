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

      def can_perform?
        player.can_play_lands?
      end

      def perform
        card.resolve!
      end
    end
  end
end
