module Magic
  module Effects
    class ReturnTargetFromGraveyardToBattlefield < TargetedEffect
      # `controller` defaults to the card's owner; pass one for "under your control".
      def initialize(controller: nil, **args)
        super(**args)
        @controller = controller
      end

      # Permanent.resolve moves the card out of the graveyard too, and records the
      # graveyard as where the permanent came from (Events::EnteredTheBattlefield#from).
      def resolve!
        Permanent.resolve(card: target, game: game, from_zone: target.zone, cast: false, controller: @controller || target.owner)
      end
    end
  end
end
