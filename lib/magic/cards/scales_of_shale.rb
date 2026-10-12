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
        trigger_effect(:grant_keyword, target: target, keyword: :lifelink)
        trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
      end
    end
  end
end
