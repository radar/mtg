module Magic
  module Cards
    ChartACourse = Sorcery("Chart a Course") do
      cost generic: 1, blue: 1
    end

    class ChartACourse < Sorcery
      def resolve!
        draw_cards(2)
        unless attacked_this_turn?
          game.add_choice(Magic::Choice::Discard.new(player: controller))
        end
      end
    end
  end
end
