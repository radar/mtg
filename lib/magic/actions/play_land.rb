module Magic
  module Actions
    class PlayLand < Action
      attr_reader :card, :face

      # `face: :back` plays a modal double-faced card's back-face land (Needleverge Pathway // Pillarverge Pathway,
      # Revitalizing Repast // Old-Growth Grove) as that land. `pay_life: true` answers a back face's "you may pay N
      # life" (see `Card#shock_life`): the player pays and it enters untapped; otherwise it enters tapped.
      def initialize(card:, face: :front, pay_life: false, **args)
        @card = card
        @face = face
        @pay_life = pay_life
        super(**args)
      end

      def pay_life? = @pay_life

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
        return play_back_face if back_face?

        card.resolve!(controller: player)
      end

      private

      def play_back_face
        life = card.back_face.shock_life
        return card.play_back_face!(controller: player) unless life

        paid = pay_life? && player.life >= life
        player.lose_life(life) if paid
        card.play_back_face!(controller: player, enters_tapped: !paid)
      end
    end
  end
end
