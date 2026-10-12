module Magic
  module Cards
    UnexpectedAssistance = Instant("Unexpected Assistance") do
      cost generic: 3, blue: 2
      convoke
    end

    class UnexpectedAssistance < Instant
      def resolve!
        draw_cards(3)
        game.add_choice(Magic::Choice::Discard.new(player: controller))
      end
    end
  end
end
