module Magic
  module Actions
    class PlayLand < Action
      attr_reader :card, :reveals

      def initialize(card:, reveals: [], reveal: nil, **args)
        @card = card
        @reveals = Array(reveal || reveals)
        super(**args)
      end

      def reveal(card)
        @reveals << card
      end

      def inspect
        "#<Actions::PlayLand name: #{card.name}, player: #{player.inspect}>"
      end

      def can_perform?
        player.can_play_lands?
      end

      def perform
        reveals.each do |revealed_card|
          player.reveal(revealed_card)
        end
        card.resolve!
      ensure
        reveals.each(&:conceal!)
      end
    end
  end
end
