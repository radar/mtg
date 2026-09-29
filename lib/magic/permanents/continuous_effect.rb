module Magic
  module Permanents
    # A single continuous effect (rule 613): a modifier pushed onto a permanent's
    # `modifiers` array, with a layer/sublayer (613.1/613.4), a creation timestamp
    # (613.7, used to break ties between two effects in the same sublayer -- see
    # ContinuousEffects), and a duration. `layer`/`sublayer` are declared once per
    # subclass via the `layer` macro below rather than threaded through every
    # `Permanent#modify_power`-style call site.
    class ContinuousEffect
      attr_reader :timestamp, :source
      # A player: the effect lasts until that player's next turn begins ("until your next turn").
      attr_accessor :until_turn_of

      # Single process-wide counter (not per-game): only relative order within a
      # game is ever compared, so this is safe and avoids threading `game` into
      # every modifier constructor across every card that creates one.
      def self.next_timestamp
        @timestamp_counter = (@timestamp_counter || 0) + 1
      end

      def self.layer(number, sublayer: nil)
        define_method(:layer) { number }
        define_method(:sublayer) { sublayer }
      end

      def layer = nil
      def sublayer = nil

      def initialize(until_eot: true, source: nil, timestamp: ContinuousEffect.next_timestamp)
        @until_eot = until_eot
        @source = source
        @timestamp = timestamp
      end

      def type_grants
        []
      end

      def power_modification
        @power_modification || 0
      end

      def toughness_modification
        @toughness_modification || 0
      end

      # 613.7: a one-shot effect lasts until end of turn unless stated otherwise;
      # a continuous effect from a static ability lasts while its source remains
      # on the battlefield (permanent, for our purposes -- ContinuousEffects
      # recomputes those from the static ability itself every pass, so they never
      # need `duration` to expire them).
      def duration
        until_eot? ? :until_end_of_turn : :permanent
      end

      def until_eot?
        @until_eot
      end
    end
  end
end
