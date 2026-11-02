module Magic
  module Cards
    QuarrelsEnd = Sorcery("Quarrel's End") do
      cost generic: 2, red: 1
    end

    class QuarrelsEnd < Sorcery
      # "As an additional cost to cast this spell, discard a card."
      def additional_costs
        [Costs::Discard.new(controller || owner)]
      end

      # "Draw two cards and create a 1/1 white Human Soldier creature token."
      def resolve!
        draw_cards(2)
        create_token(token: Tokens::HumanSoldier)
        super
      end
    end
  end
end
