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
        effect = Magic::Effects::DrawCards.new(source: self, player: target, number_to_draw: (target.library.count / 2.0).ceil)
        game.add_effect(effect)

        effect = Magic::Effects::LoseLife.new(source: self, targets: [target], life: (target.life / 2.0).ceil)
        game.add_effect(effect)
      end
    end
  end
end
