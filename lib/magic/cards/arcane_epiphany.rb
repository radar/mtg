module Magic
  module Cards
    ArcaneEpiphany = Instant("Arcane Epiphany") do
      cost generic: 3, blue: 2
    end

    class ArcaneEpiphany < Instant
      def self_mana_cost_adjustment
        controller = self.controller || owner
        { generic: -> { (controller.permanents.by_type("Wizard").any?) ? -1 : 0 } }
      end

      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 3)
      end
    end
  end
end
