module Magic
  module Effects
    class ReturnTargetFromGraveyardToBattlefield < TargetedEffect
      def resolve!
        game.add_effect(Effects::MoveCardZone.new(source: source, target: target, from: target.zone, to: game.battlefield))
        Permanent.resolve(card: target, game: game, cast: false)
      end
    end
  end
end
