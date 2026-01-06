module Magic
  module Effects
    class RevealCards < TargetedEffect
      def inspect
        "#<Effects::RevealCards player=#{source.controller.name} cards=#{target.map(&:name).join(", ")}>"
      end

      def resolve!
        game.notify!(
          Events::CardsRevealed.new(cards: Array(target))
        )
      end
    end
  end
end
