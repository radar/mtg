# frozen_string_literal: true

module Magic
  # Roadmap C2b: enumerates the actions +player+ could legally attempt right
  # now. Builds candidate `Action` instances (no targets or costs chosen yet
  # -- that's a separate decision, `Agent#choose_targets`/`#choose_mana_payment`)
  # and keeps the ones C1's own legality predicate accepts, so this never
  # duplicates `illegal_reason`'s rules.
  #
  # A candidate is kept when `action.legal?` and, where the action class
  # defines `can_perform?` (Cast, PlayLand, Cycle), it can also afford it.
  # `ActivateAbility`, `ActivateLoyaltyAbility` and `DeclareAttacker` have no
  # such affordability check (costs there are too heterogeneous to check
  # generically without choosing targets first -- see roadmap G3), so a
  # legal-but-unaffordable ability can still show up here; paying will fail
  # the same way it would for a caller that tried it directly.
  #
  # `nil` is always included, meaning "pass" (see `Magic::Agent#choose_action`).
  class LegalActions
    def initialize(game:, player:)
      @game = game
      @player = player
    end

    def call
      [nil, *castable_spells, *playable_lands, *cyclable_cards, *activatable_abilities, *activatable_loyalty_abilities, *declarable_attackers]
    end

    private

    attr_reader :game, :player

    def castable_spells
      cast_candidate_cards.flat_map do |card|
        candidates = [keep(Actions::Cast.new(game: game, player: player, card: card))]
        candidates << keep(Actions::Cast.new(game: game, player: player, card: card, flashback: true)) if card.zone&.graveyard? && card.respond_to?(:flashback_cost)
        candidates
      end.compact
    end

    # Own hand and graveyard, plus the top of the library and everything in exile: the
    # zones `Action#in_permitted_zone?` (via `Cast#illegal_reason`) might allow a cast
    # from, either always (hand) or when some static ability/emblem/play permission says
    # so. Passing every candidate through `legal?` is what actually filters this down.
    def cast_candidate_cards
      [
        *player.hand.cards,
        *player.graveyard.cards,
        *([player.library.first].compact),
        *player.exile.cards,
      ]
    end

    def playable_lands
      cast_candidate_cards.select { |card| card.land? }.filter_map { |card| keep(Actions::PlayLand.new(game: game, player: player, card: card)) }
    end

    def cyclable_cards
      player.hand.cards.select { |card| card.respond_to?(:cycling_cost) && card.cycling_cost }
        .filter_map { |card| keep(Actions::Cycle.new(game: game, player: player, card: card)) }
    end

    def activatable_abilities
      player.permanents.flat_map(&:activated_abilities).filter_map do |ability|
        keep(Actions::ActivateAbility.new(game: game, player: player, ability: ability))
      end
    end

    def activatable_loyalty_abilities
      player.planeswalkers.flat_map(&:loyalty_abilities).filter_map do |ability|
        keep(Actions::ActivateLoyaltyAbility.new(game: game, player: player, ability: ability))
      end
    end

    def declarable_attackers
      return [] unless game.current_turn.step?(:declare_attackers) && game.current_turn.active_player == player

      player.creatures.flat_map do |attacker|
        game.opponents(player).filter_map do |target|
          keep(Actions::DeclareAttacker.new(game: game, player: player, attacker: attacker, target: target))
        end
      end
    end

    def keep(action)
      return nil unless action.legal?
      return nil if action.respond_to?(:can_perform?) && !action.can_perform?

      action
    end
  end
end
