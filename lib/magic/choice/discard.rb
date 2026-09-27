module Magic
  class Choice
    class Discard < Magic::Choice
      attr_reader :player, :cards

      # `actor` is optional (nil by default) for existing callers that never subclass
      # this to run a follow-up effect ("discard a card. If you do, X") and so never
      # need `game`/`controller`/`trigger_effect` on the choice itself.
      def initialize(player:, actor: nil)
        @actor = actor
        @player = player
        @cards = player.hand
      end

      def resolve!(card:)
        card.move_to_graveyard!
      end
    end
  end
end
