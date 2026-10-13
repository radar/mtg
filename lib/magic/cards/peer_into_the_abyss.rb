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
        draw_cards((target.library.count / 2.0).ceil, player: target)
        lose_life(target, (target.life / 2.0).ceil)
      end
    end
  end
end
