module Magic
  module Cards
    PeerIntoTheAbyss = Sorcery("Peer Into the Abyss") do
      cost black: 3, generic: 4

      def single_target?
        true
      end

      def target_choices
        game.players
      end

      def resolve!(target:)
        trigger_effect(:draw_cards, player: target, number_to_draw: (target.library.count / 2.0).ceil)
        trigger_effect(:lose_life, target: target, life: (target.life / 2.0).ceil)
      end
    end
  end
end
