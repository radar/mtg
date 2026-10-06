module Magic
  class Choice
    class Discard < Magic::Choice
      attr_reader :player, :cards, :amount

      # `actor` is optional (nil by default) for existing callers that never subclass
      # this to run a follow-up effect ("discard a card. If you do, X") and so never
      # need `game`/`controller`/`trigger_effect` on the choice itself.
      #
      # `amount` is how many cards the player must discard in all (the cleanup step: down to
      # maximum hand size). They may answer with up to that many at a time (`cards:`); whatever
      # is left over is asked for again.
      def initialize(player:, actor: nil, amount: 1)
        @actor = actor
        @player = player
        @cards = player.hand
        @amount = amount
      end

      def prompt
        noun = amount == 1 ? "card" : "cards"
        "Discard #{amount} #{noun}"
      end

      def resolve!(card: nil, cards: nil)
        chosen = cards || [card]
        raise ArgumentError, "Choose between 1 and #{amount} cards to discard." unless chosen.any? && chosen.size <= amount
        raise ArgumentError, "Choose different cards to discard." unless chosen.uniq.size == chosen.size

        chosen.each(&:move_to_graveyard!)
        remaining = amount - chosen.size
        player.game.add_choice(self.class.new(player: player, actor: @actor, amount: remaining)) if remaining.positive?
      end
    end
  end
end
