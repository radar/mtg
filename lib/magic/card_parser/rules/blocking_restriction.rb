# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ can't block." / "~ can't be blocked." / "~ can't be blocked by Humans." All are checked when
      # blockers are declared (CombatPhase#can_block?; `can_be_blocked?(blocker)` gets the would-be blocker).
      class BlockingRestriction < Data.define(:method, :creature_type)
        include Rule

        LINE = /\A~ can't (?:(?<be>be blocked)(?: by (?<type>[A-Z][a-z]+(?:-[A-Z][a-z]+)?s))?|block)\.?\z/

        def initialize(method:, creature_type: nil) = super

        def self.parse(line)
          return unless (m = LINE.match(line))

          new(method: m[:be] ? "can_be_blocked?" : "can_block?", creature_type: m[:type] && CreatureType.singular(m[:type]))
        rescue UnsupportedCard
          nil
        end

        def kinds = %i[creature]

        def body_source
          return "def #{method}(blocker) = !blocker.type?(#{creature_type.inspect})\n" if creature_type

          "def #{method}(_) = false\n"
        end
      end
    end
  end
end
