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
  # `nil` is always included (last), meaning "pass" (see `Magic::Agent#choose_action`).
  class LegalActions
    def initialize(game:, player:)
      @game = game
      @player = player
    end

    def call
      [*castable_spells, *playable_lands, *cyclable_cards, *activatable_abilities, *activatable_loyalty_abilities,
       *declarable_attackers, *declarable_blockers, nil]
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
        # Mana abilities don't use the stack (`Actions::ActivateManaAbility#uses_priority?`
        # is false) and resolve immediately in `#perform`; `Player#activate_ability` picks
        # the class the same way.
        action_class = ability.is_a?(Magic::ManaAbility) ? Actions::ActivateManaAbility : Actions::ActivateAbility
        keep(action_class.new(game: game, player: player, ability: ability))
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

    # One candidate per (attacking creature, potential blocker) pair, for whichever player
    # is asked -- `Actions::DeclareBlocker#illegal_reason` rejects the ones that aren't
    # this player's creatures or aren't legal blocks, so this doesn't need to work out the
    # defending player itself.
    def declarable_blockers
      return [] unless game.current_turn.step?(:declare_blockers)

      game.current_turn.attacks.flat_map do |attack|
        player.creatures.filter_map do |blocker|
          keep(Actions::DeclareBlocker.new(game: game, player: player, blocker: blocker, attacker: attack.attacker))
        end
      end
    end

    def keep(action)
      return nil unless action.legal?
      return nil if action.respond_to?(:can_perform?) && !action.can_perform?
      # illegal_reason deliberately doesn't check {T}-cost payability (see CLAUDE.md
      # "Action Legality" -- it's checked at payment time instead), but an enumeration of
      # what's *currently* activatable has to exclude an already-tapped/summoning-sick
      # source, or a caller that tries the "legal" action gets an IllegalAction from
      # ActivateAbility#pay for a reason this method never surfaced.
      if action.respond_to?(:has_cost?) && action.has_cost?(Costs::SelfTap)
        return nil if action.costs.find { |cost| cost.is_a?(Costs::SelfTap) }.unpayable_reason
      end

      action
    end
  end
end
