module Magic
  class ReplacementEffect
    # Base for "if a player would put one or more counters on a permanent or player" replacements
    # (Vorinclex, Monstrous Raider; Hardened Scales-style cards). Subclasses decide which player's
    # counters they affect (`applies?`) and how the amount changes (`new_amount`).
    class CounterAmountChange < ReplacementEffect
      # The effect classes this replacement watches; override to narrow (e.g. permanents only).
      def self.matchers = [Effects::AddCounterToPermanent, Effects::AddCounterToPlayer]

      # Pairs for a card's `replacement_effects` (an array of [matcher, replacement_effect]).
      def self.registrations = matchers.map { |matcher| [matcher, self] }

      def call(effect)
        effect.with_amount(new_amount(effect.amount))
      end

      private

      # The player putting the counters is the controller of the effect's source.
      def putter(effect) = effect.source&.controller
    end
  end
end
