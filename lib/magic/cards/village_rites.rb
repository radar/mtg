module Magic
  module Cards
    class VillageRites < Instant
      card_name "Village Rites"
      cost black: 1

      def additional_costs
        [Costs::Sacrifice.new(self, controller.creatures)]
      end

      def resolve!
        draw_cards(2)
      end
    end
  end
end
