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
        legal?
      end

      def illegal_reason
        return "#{card.name} is not a land" unless card.land?
        return "#{card.name} is not in a zone it can be played from" unless playable_from_current_zone?

        if (reason = sorcery_speed_reason)
          return "lands can only be played at sorcery speed, but #{reason}"
        end

        return "#{player.inspect} has already played the maximum number of lands this turn" unless player.can_play_lands?
      end

      def perform
        card.resolve!
      end

      private

      def playable_from_current_zone?
        card.zone&.hand? || (
          card.zone&.library? &&
          card == player.library.first &&
          game.battlefield.static_abilities.any? do |ability|
            ability.respond_to?(:permits_casting_from_top?) && ability.permits_casting_from_top?(card)
          end
        )
      end
    end
  end
end
