module Magic
  # Permissions to play cards from exile that outlast whatever granted them ("Until the
  # end of your next turn, you may play that card", from a resolved spell). Checked by
  # Action#in_permitted_zone? alongside static abilities.
  class PlayPermissions
    # Lasts through the end of the player's next turn: their next one after this, if
    # it's their turn now.
    # `this_turn` permissions ("you may cast the exiled cards this turn") end with the turn
    # they were granted on instead.
    # `graveyard`: the card is castable from the graveyard (Zul Ashur) rather than from exile.
    # `forever`: lasts for as long as the card stays in exile (Thranduil's Decree).
    Permission = Data.define(:card, :player, :granted_on_turn, :this_turn, :free, :graveyard, :forever) do
      def initialize(graveyard: false, forever: false, **args) = super

      def permits?(game, card, player)
        card.equal?(self.card) && player == self.player && (graveyard ? card.zone&.graveyard? : card.zone&.exile?) && !expired?(game)
      end

      def expired?(game)
        return false if forever
        return game.current_turn.number > granted_on_turn if this_turn

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
      @permissions << Permission.new(card:, player:, granted_on_turn: @game.current_turn.number, this_turn: false, free: false)
    end

    # "You may cast that card without paying its mana cost for as long as it remains exiled."
    def grant_free_while_exiled(card:, player:)
      @permissions << Permission.new(card:, player:, granted_on_turn: @game.current_turn.number, this_turn: false, free: true, forever: true)
    end

    # `free: true`: "you may cast it without paying its mana cost" (Dream Harvest).
    # `from_graveyard: true`: "you may cast target Zombie card from your graveyard this turn" (Zul Ashur).
    def grant_until_end_of_turn(card:, player:, free: false, from_graveyard: false)
      @permissions << Permission.new(card:, player:, granted_on_turn: @game.current_turn.number, this_turn: true, free:, graveyard: from_graveyard)
    end

    # "Until your next end step, you may play those cards": through this turn when it's your turn
    # now, else through your next turn.
    def grant_until_next_end_step(card:, player:)
      if @game.current_turn.active_player == player
        grant_until_end_of_turn(card:, player:)
      else
        grant_until_end_of_next_turn(card:, player:)
      end
    end

    # Whether a permission lets `player` cast `card` without paying its mana cost.
    def free_cast?(card, player)
      @permissions.reject! { _1.expired?(@game) }
      @permissions.any? { _1.free && _1.permits?(@game, card, player) }
    end

    def permits?(card, player)
      @permissions.reject! { _1.expired?(@game) }
      @permissions.any? { _1.permits?(@game, card, player) }
    end
  end
end
