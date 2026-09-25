module Magic
  module Cards
    FlickACoin = Instant("Flick a Coin") do
      cost "{2}{R}"
    end

    class FlickACoin < Instant
      def single_target?
        true
      end

      def target_choices
        game.any_target
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, damage: 1, target: target)
        trigger_effect(:create_token, token_class: Tokens::Treasure)
        trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end
  end
end
