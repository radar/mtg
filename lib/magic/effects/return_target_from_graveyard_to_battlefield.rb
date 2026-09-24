module Magic
  module Effects
    class ReturnTargetFromGraveyardToBattlefield < TargetedEffect
      # Permanent.resolve moves the card out of the graveyard too, and records the
      # graveyard as where the permanent came from (Events::EnteredTheBattlefield#from).
      def resolve!
        Permanent.resolve(card: target, game: game, from_zone: target.zone, cast: false)
      end
    end
  end
end
