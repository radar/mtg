module Magic
  module Cards
    ScalesOfShale = Instant("Scales of Shale") do
      cost generic: 2, black: 1
    end

    class ScalesOfShale < Instant
      def self_mana_cost_adjustment
        controller = self.controller || owner
        { generic: -> { -controller.permanents.by_type("Lizard").count } }
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 2, 0)
        give_keyword(target, :lifelink)
        give_keyword(target, :indestructible)
      end
    end
  end
end
