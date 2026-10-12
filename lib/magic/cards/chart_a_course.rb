module Magic
  module Cards
    ChartACourse = Sorcery("Chart a Course") do
      cost generic: 1, blue: 1
    end

    class ChartACourse < Sorcery
      def resolve!
        draw_cards(2)
        unless game.current_turn.events.any? { |e| e.is_a?(Events::CreatureAttacked) && e.attacker.controller == controller }
          game.add_choice(Magic::Choice::Discard.new(player: controller))
        end
      end
    end
  end
end
