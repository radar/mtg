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
        trigger(:draw_card, player: target, number_to_draw: (target.library.count / 2.0).ceil)
        trigger(:lose_life, targets: [target], life: (target.life / 2.0).ceil)
      end
    end
  end
end
