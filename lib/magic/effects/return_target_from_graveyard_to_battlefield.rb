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

      # Permanent.resolve moves the card out of the graveyard too, and records the
      # graveyard as where the permanent came from (Events::EnteredTheBattlefield#from).
      def resolve!
        permanent = Permanent.resolve(card: target, game: game, from_zone: target.zone, cast: false, controller: @controller || target.owner)
        @counters.each { |type, amount| permanent.add_counter(type, amount: amount) } if permanent
        permanent
      end
    end
  end
end
