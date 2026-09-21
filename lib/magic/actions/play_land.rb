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

      def illegal_reason
        return "#{card.name} is not in a zone it can be played from" unless in_permitted_zone?(card)

        if (reason = sorcery_speed_reason)
          return "lands can only be played at sorcery speed, but #{reason}"
        end

        "#{player.inspect} cannot play any more lands this turn" unless player.can_play_lands?
      end

      def perform
        card.resolve!
      end
    end
  end
end
