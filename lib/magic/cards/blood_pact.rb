module Magic
  module Cards
    class BloodPact < Instant
      card_name "Blood Pact"
      cost generic: 2, black: 1

      def single_target? = true

      def target_choices = game.players

      # "Target player draws two cards and loses 2 life."
      def resolve!(target:)
        draw_cards(2, player: target)
        lose_life(target, 2)
      end
    end
  end
end
