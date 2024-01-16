module Magic
  module Choice
    class Discard < Magic::Choice::Effect
      attr_reader :player, :cards

      def initialize(player:)
        @player = player
        @cards = player.hand
      end

      def choose(card)
        card.move_to_graveyard!
      end
    end
  end
end
