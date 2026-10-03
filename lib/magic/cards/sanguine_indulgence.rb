module Magic
  module Cards
    SanguineIndulgence = Sorcery("Sanguine Indulgence") do
      cost generic: 3, black: 1
    end

    class SanguineIndulgence < Sorcery
      def self_mana_cost_adjustment
        controller = self.controller || owner
        { generic: -> { (game.current_turn.events.select { |e| e.is_a?(Events::LifeGain) && e.player == controller }.sum(&:life) >= 3) ? -3 : 0 } }
      end

      def target_choices
        controller.graveyard.cards.select { _1.type?("Creature") }
      end

      def resolve!(targets:)
        targets.uniq.each { _1.move_to_hand! }
      end
    end
  end
end
