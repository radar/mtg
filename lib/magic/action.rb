module Magic
  class Action
    include ResolvesWithArgs

    attr_reader :game, :player

    def initialize(game:, player:)
      @game = game
      @player = player
    end

    # Why this action cannot be taken right now (timing, zone, limits), or nil if it can.
    # Checked by Turn#take_action just before #perform, i.e. after any costs have been
    # paid, so it must not check whether costs are payable; see #can_perform? for that.
    def illegal_reason
      nil
    end

    def legal?
      illegal_reason.nil?
    end

    private

    # Whether +card+ is somewhere its owner may cast or play it from: hand (or graveyard, for
    # flashback), or the top of the library / exile / graveyard when a static ability or emblem
    # permits it.
    def in_permitted_zone?(card, flashback: false)
      zone = card.zone
      return true unless zone # a card that was never placed in a zone (bare spec fixture) is treated as being in hand
      return zone.graveyard? if flashback && zone.graveyard?
      return true if zone.hand? && !flashback

      (zone.library? && card == player.library.first && permitted_by_static_ability?(:permits_casting_from_top?, card)) ||
        (zone.exile? && (card.on_adventure || permitted_by_static_ability?(:permits_casting_from_exile?, card) ||
                         game.play_permissions.permits?(card, player))) ||
        (zone.graveyard? && permitted_by_emblem?(:permits_casting_from_graveyard?, card))
    end

    # A permission method may take the player casting the card as a second argument
    # ("you may cast it": only its controller may).
    def permitted_by_static_ability?(permission, card)
      game.battlefield.static_abilities.any? do |ability|
        next false unless ability.respond_to?(permission)

        ability.method(permission).arity == 1 ? ability.public_send(permission, card) : ability.public_send(permission, card, player)
      end
    end

    def permitted_by_emblem?(permission, card)
      game.emblems.any? do |emblem|
        emblem.owner == player && emblem.respond_to?(permission) && emblem.public_send(permission, card)
      end
    end


    # Rule 307.1 / 601.3: sorcery-speed actions need an empty stack in the active
    # player's main phase.
    def sorcery_speed_reason
      turn = game.current_turn
      return "it is not #{player.inspect}'s turn" unless turn.active_player == player
      return "it is not a main phase" unless turn.main_phase?
      return "the stack is not empty" unless game.stack.empty?
    end
  end
end
