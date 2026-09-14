module Magic
  module Cards
    class CatharticReunion < Sorcery
      card_name "Cathartic Reunion"
      cost generic: 1, red: 1

      def additional_costs
        [Costs::DiscardCards.new(controller, 2)]
      end

      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 3)
      end
    end
  end
end
