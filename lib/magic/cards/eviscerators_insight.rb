module Magic
  module Cards
    EvisceratorsInsight = Instant("Eviscerator's Insight") do
      cost generic: 1, black: 1
      flashback Costs::Mana.new(generic: 4, black: 1)
    end

    class EvisceratorsInsight < Instant
      # "As an additional cost to cast this spell, sacrifice an artifact or creature."
      def additional_costs
        [Costs::Sacrifice.new(self, controller.permanents.select { _1.type?("Artifact") || _1.type?("Creature") })]
      end

      def resolve!
        draw_cards(2)
      end
    end
  end
end
