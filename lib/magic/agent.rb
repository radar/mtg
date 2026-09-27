# frozen_string_literal: true

module Magic
  # Roadmap C2a: the seam for "ask the player what to do". A `Player` can be
  # given an `Agent` (see `Player#agent`); nothing in the engine calls these
  # methods yet (that's C2b/C2c), so this is the contract subclasses implement
  # and specs can exercise directly in the meantime.
  #
  # Every method here is a decision a player makes and takes the raw options
  # available (already filtered to be legal), plus the game for context. The
  # base class documents the contract by raising; subclasses override what
  # they support.
  class Agent
    # Choose which action to take from the actions currently available.
    # `legal_actions` is whatever `Game#legal_actions(player)` (C2b) would
    # enumerate: castable spells, playable lands, activatable abilities,
    # attack/block declarations, or `nil`/pass.
    def choose_action(game, legal_actions)
      raise NotImplementedError, "#{self.class} must implement #choose_action"
    end

    # Choose `count` targets from `targets` (already filtered to legal ones).
    def choose_targets(game, targets, count: 1)
      raise NotImplementedError, "#{self.class} must implement #choose_targets"
    end

    # Choose how to assign blockers to attackers. `attackers` is the list of
    # attacking permanents this agent's creatures may block. Returns a
    # mapping of `blocker => attacker`.
    def choose_blockers(game, attackers)
      raise NotImplementedError, "#{self.class} must implement #choose_blockers"
    end

    # Choose how to pay a mana cost from the mana currently available.
    # Returns a payment mapping suitable for `Player#pay_mana`.
    def choose_mana_payment(game, cost, available)
      raise NotImplementedError, "#{self.class} must implement #choose_mana_payment"
    end

    # Answer a pending `Choice` (see `lib/magic/choice.rb` and its
    # subclasses). Returns whatever `Stack#resolve_choice!` expects for that
    # choice's kind.
    def resolve_choice(game, choice)
      raise NotImplementedError, "#{self.class} must implement #resolve_choice"
    end
  end
end
