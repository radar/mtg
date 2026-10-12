module Magic
  module Cards
    RowdyResearch = Instant("Rowdy Research") do
      cost generic: 6, blue: 1
    end

    class RowdyResearch < Instant
      # "This spell costs {1} less to cast for each creature that attacked this turn." Any player's creatures, each
      # counted once however many times it was declared as an attacker.
      def self_mana_cost_adjustment
        { generic: -> { -game.current_turn.events.select { _1.is_a?(Events::CreatureAttacked) }.map(&:attacker).uniq.count } }
      end

      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 3)
      end
    end
  end
end
