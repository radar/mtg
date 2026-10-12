module Magic
  module Effects
    class ReturnTargetFromGraveyardToBattlefield < TargetedEffect
      # `controller` defaults to the card's owner; pass one for "under your control".
      # `counters`: counters it enters with, as { "finality" => 1 }.
      def initialize(controller: nil, counters: {}, **args)
        super(**args)
        @controller = controller
        @counters = counters
      end

      # Permanent.put_onto_battlefield moves the card out of the graveyard too, and records the
      # graveyard as where the permanent came from (Events::EnteredTheBattlefield#from).
      def resolve!
        Permanent.put_onto_battlefield(card: target, game: game, from_zone: target.zone, controller: @controller || target.owner, counters: @counters)
      end
    end
  end
end
