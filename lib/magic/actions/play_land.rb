module Magic
  module Actions
    class PlayLand < Action
      attr_reader :card, :face

      # `face: :back` plays a modal double-faced card's back-face land (Needleverge Pathway // Pillarverge Pathway,
      # Revitalizing Repast // Old-Growth Grove) as that land.
      def initialize(card:, face: :front, **args)
        @card = card
        @face = face
        super(**args)
      end

      def back_face?
        face == :back && !card.back_face.nil?
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
        # A land played from an opponent's exile (Valgavoth) comes under the control of whoever plays it.
        # A back face enters as the back face (a spell // land card's land), with the back face's "enters tapped".
        return card.play_back_face!(controller: player) if back_face?

        card.resolve!(controller: player)
      end
    end
  end
end
