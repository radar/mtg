module Magic
  class Choice
    class Discard < Magic::Choice
      attr_reader :player, :cards

      def initialize(player:)
        @player = player
        @cards = player.hand
      end

      def resolve!(card:)
        card.move_to_graveyard!
      end
    end
  end
end
