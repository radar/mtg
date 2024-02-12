module Magic
  module Cards
    Discontinuity = Instant("Discontinuity") do
      def cost
        Costs::Mana.new(generic: 3, blue: 3)
          .adjusted_by({ generic: -2, blue: -2 }, -> { game.current_turn.active_player == controller })
      end
    end

    class Discontinuity < Instant
      def resolve!
        game.stack.exile!
        exile!

        game.current_turn.end!
      end
    end
  end
end
