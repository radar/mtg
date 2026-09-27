# frozen_string_literal: true

module Magic
  module Agents
    # An `Agent` that always takes the first option it is offered, or passes
    # when there is nothing to do. Trivial by design (roadmap C2): it exists
    # so C2c's game runner has something to drive both players with, and so
    # `Game#run!`/fuzz testing (L2) can play whole games without a real
    # decision-maker.
    class FirstLegalAgent < Agent
      # `legal_actions` may include `nil` for "pass"; take the first entry,
      # which is a pass if that is all that is offered.
      def choose_action(game, legal_actions) = legal_actions.first

      def choose_targets(game, targets, count: 1) = targets.first(count)

      # No creature blocks anything: cheapest legal (if unenthusiastic) way
      # to answer a block decision without picking favourites among targets.
      def choose_blockers(game, attackers) = {}

      def choose_mana_payment(game, cost, available) = available.first

      # `Choice` subclasses each expect a different answer shape (see
      # `lib/magic/choice/*.rb`), and none exposes a generic "options" list
      # to pick a first entry from, so there is no trivial universal answer
      # here yet. Script one with `ScriptedAgent` until C2c gives choices a
      # shared query surface.
      def resolve_choice(game, choice)
        raise NotImplementedError, "#{self.class} has no generic answer for #{choice.class}"
      end
    end
  end
end
