# frozen_string_literal: true

module Magic
  module Agents
    # An `Agent` driven by a pre-scripted queue of answers, for specs that
    # want to exercise a decision seam without hand-simulating a player.
    # Each `answers` entry is consumed, in order, by whichever `choose_*` or
    # `resolve_choice` call comes next; the queue does not care which method
    # asked, so script exactly the calls the scenario under test will make.
    class ScriptedAgent < Agent
      class OutOfAnswers < StandardError; end

      def initialize(answers: [])
        @answers = answers.dup
      end

      def choose_action(game, legal_actions) = next_answer

      def choose_targets(game, targets, count: 1) = next_answer

      def choose_blockers(game, attackers) = next_answer

      def choose_mana_payment(game, cost, available) = next_answer

      def resolve_choice(game, choice) = next_answer

      private

      def next_answer
        raise OutOfAnswers, "#{self.class} has no more scripted answers" if @answers.empty?

        @answers.shift
      end
    end
  end
end
