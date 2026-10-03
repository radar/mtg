# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ can't block." / "~ can't be blocked." / "~ can't be blocked by Humans." / "~ can't be blocked as
      # long as there are seven or more cards in your graveyard." All are checked when blockers are
      # declared (CombatPhase#can_block?; `can_be_blocked?(blocker)` gets the would-be blocker).
      class BlockingRestriction < Data.define(:method, :creature_type, :condition)
        include Rule

        LINE = /\A~ can't (?:(?<be>be blocked)(?: by (?<type>[A-Z][a-z]+(?:-[A-Z][a-z]+)?s))?|block)(?: as long as (?<condition>[^.]+?))?\.?\z/

        def initialize(method:, creature_type: nil, condition: nil) = super

        def self.parse(line)
          return unless (m = LINE.match(line))
          return if m[:condition] && m[:type]

          condition = Condition.parse(m[:condition]) or return if m[:condition]
          new(method: m[:be] ? "can_be_blocked?" : "can_block?", creature_type: m[:type] && CreatureType.singular(m[:type]),
              condition: condition&.gsub(/\bsource\b/, "self"))
        rescue UnsupportedCard
          nil
        end

        def kinds = %i[creature]

        def body_source
          return "def #{method}(blocker) = !blocker.type?(#{creature_type.inspect})\n" if creature_type
          return "def #{method}(_) = !(#{condition})\n" if condition

          "def #{method}(_) = false\n"
        end
      end
    end
  end
end
