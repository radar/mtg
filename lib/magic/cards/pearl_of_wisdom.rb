module Magic
  module Cards
    PearlOfWisdom = Sorcery("Pearl of Wisdom") do
      cost generic: 2, blue: 1
    end

    class PearlOfWisdom < Sorcery
      def self_mana_cost_adjustment
        controller = self.controller || owner
        { generic: -> { (controller.permanents.by_type("Otter").any?) ? -1 : 0 } }
      end

      def resolve!
        draw_cards(2)
      end
    end
  end
end
