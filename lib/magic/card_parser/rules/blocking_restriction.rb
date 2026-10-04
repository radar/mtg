# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ can't block." / "~ can't be blocked." / "~ can't be blocked by Humans." / "~ can't be blocked by
      # creatures with power 2 or less." / "~ can't be blocked as long as there are seven or more cards in your
      # graveyard." All are checked when blockers are declared (CombatPhase#can_block?;
      # `can_be_blocked?(blocker)` gets the would-be blocker).
      class BlockingRestriction < Data.define(:method, :creature_type, :condition, :max_power)
        include Rule

        LINE = /\A~ can't (?:(?<be>be blocked)(?: by (?:creatures with power (?<power>\d+) or less|(?<type>[A-Z][a-z]+(?:-[A-Z][a-z]+)?s)))?|block)(?: as long as (?<condition>[^.]+?))?\.?\z/

        def initialize(method:, creature_type: nil, condition: nil, max_power: nil) = super

        def self.parse(line)
          return unless (m = LINE.match(line))
          return if m[:condition] && (m[:type] || m[:power])

          condition = Condition.parse(m[:condition]) or return if m[:condition]
          new(method: m[:be] ? "can_be_blocked?" : "can_block?", creature_type: m[:type] && CreatureType.singular(m[:type]),
              condition: condition&.gsub(/\bsource\b/, "self"), max_power: m[:power]&.to_i)
        rescue UnsupportedCard
          nil
        end

        def kinds = %i[creature]

        def body_source
          return "def #{method}(blocker) = !blocker.type?(#{creature_type.inspect})\n" if creature_type
          return "def #{method}(blocker) = blocker.power > #{max_power}\n" if max_power
          return "def #{method}(_) = !(#{condition})\n" if condition

          "def #{method}(_) = false\n"
        end
      end
    end
  end
end
