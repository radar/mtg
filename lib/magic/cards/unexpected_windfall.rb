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
        draw_cards(2)
        create_token(token:Tokens::Treasure, amount: 2)
      end
    end
  end
end
