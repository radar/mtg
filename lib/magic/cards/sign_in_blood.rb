module Magic
  module Cards
    class SignInBlood < Sorcery
      card_name "Sign in Blood"
      cost black: 2

      def single_target? = true

      def target_choices = game.players

      # "Target player draws two cards and loses 2 life."
      def resolve!(target:)
        trigger_effect(:draw_cards, player: target, number_to_draw: 2)
        lose_life(target, 2)
      end
    end
  end
end
