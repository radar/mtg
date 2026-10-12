module Magic
  module Cards
    class CatharticReunion < Sorcery
      card_name "Cathartic Reunion"
      cost generic: 1, red: 1

      def additional_costs
        [Costs::DiscardCards.new(controller, 2)]
      end

      def resolve!
        draw_cards(3)
      end
    end
  end
end
