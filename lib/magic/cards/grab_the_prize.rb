module Magic
  module Cards
    GrabThePrize = Sorcery("Grab The Prize") do
      cost generic: 1, red: 1
    end

    class GrabThePrize < Sorcery
      # Remembers the discarded card so resolution can check whether it was a land.
      class DiscardCost < Costs::Discard
        attr_reader :discarded

        def pay(player:, payment:)
          super
          @discarded = payment
        end
      end

      def discard_cost
        @discard_cost ||= DiscardCost.new(controller)
      end

      def additional_costs
        [discard_cost]
      end

      def resolve!
        discarded = discard_cost.discarded
        draw_cards(2)
        return if discarded.nil? || discarded.land?

        game.opponents(controller).each do |opponent|
          deal_damage(2, to: opponent)
        end
      end
    end
  end
end
