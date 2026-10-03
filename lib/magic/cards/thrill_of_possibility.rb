module Magic
  module Cards
    ThrillOfPossibility = Instant("Thrill of Possibility") do
      cost generic: 1, red: 1
    end

    class ThrillOfPossibility < Instant
      # Discard a card as an additional cost to cast this card.
      def additional_costs
        [Costs::Discard.new(controller || owner)]
      end

      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 2)
      end
    end
  end
end
