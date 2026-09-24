module Magic
  module Effects
    class ReturnTargetFromGraveyardToBattlefield < TargetedEffect
      # `controller` defaults to the card's owner; pass one for "under your control".
      def initialize(controller: nil, **args)
        super(**args)
        @controller = controller
      end

      def resolve!
        game.add_effect(Effects::MoveCardZone.new(source: source, target: target, from: target.zone, to: game.battlefield))
        Permanent.resolve(card: target, game: game, cast: false, controller: @controller || target.owner)
      end
    end
  end
end
