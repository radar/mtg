module Magic
  module Cards
    class MindSpiral < Sorcery
      card_name "Mind Spiral"
      cost generic: 4, blue: 1
      gift :tapped_fish

      def multi_target? = gift_promised?

      def target_choices
        return game.players unless gift_promised?

        [game.players, battlefield.not_controlled_by(controller).creatures]
      end

      # Target player draws three cards. If the gift was promised, tap target creature an opponent
      # controls and put a stun counter on it.
      def resolve!(targets:)
        trigger_effect(:draw_cards, player: targets.first, number_to_draw: 3)
        return unless gift_promised?

        creature = targets[1]
        trigger_effect(:tap, target: creature)
        add_counter("stun", to: creature)
      end
    end
  end
end
