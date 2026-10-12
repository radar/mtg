module Magic
  module Cards
    class BloodPact < Instant
      card_name "Blood Pact"
      cost generic: 2, black: 1

      def single_target? = true

      def target_choices = game.players

      # "Target player draws two cards and loses 2 life."
      def resolve!(target:)
        trigger_effect(:draw_cards, player: target, number_to_draw: 2)
        trigger_effect(:lose_life, target: target, life: 2)
      end
    end
  end
end
