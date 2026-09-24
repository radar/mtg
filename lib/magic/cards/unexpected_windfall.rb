module Magic
  module Cards
    UnexpectedWindfall = Instant("Unexpected Windfall") do
      cost "{2}{R}{R}"
    end

    class UnexpectedWindfall < Instant
      def additional_costs
        [Costs::Discard.new(controller)]
      end

      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 2)
        trigger_effect(:create_token, token_class: Tokens::Treasure, amount: 2)
      end
    end
  end
end
