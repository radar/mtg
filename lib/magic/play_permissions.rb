module Magic
  # Permissions to play cards from exile that outlast whatever granted them ("Until the
  # end of your next turn, you may play that card", from a resolved spell). Checked by
  # Action#in_permitted_zone? alongside static abilities.
  class PlayPermissions
    # Lasts through the end of the player's next turn: their next one after this, if
    # it's their turn now.
    Permission = Data.define(:card, :player, :granted_on_turn) do
      def permits?(game, card, player)
        card.equal?(self.card) && player == self.player && card.zone&.exile? && !expired?(game)
      end

      def expired?(game)
        game.turns.any? do |turn|
          turn.active_player == player && turn.number > granted_on_turn && turn.number < game.current_turn.number
        end
      end
    end

    def initialize(game)
      @game = game
      @permissions = []
    end

    def grant_until_end_of_next_turn(card:, player:)
      @permissions << Permission.new(card:, player:, granted_on_turn: @game.current_turn.number)
    end

    def permits?(card, player)
      @permissions.reject! { _1.expired?(@game) }
      @permissions.any? { _1.permits?(@game, card, player) }
    end
  end
end
