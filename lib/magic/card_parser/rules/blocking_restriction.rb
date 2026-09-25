# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ can't block." / "~ can't be blocked." Both are checked when blockers are
      # declared (CombatPhase#can_block?).
      class BlockingRestriction < Data.define(:method)
        include Rule

        LINE = /\A~ can't (?:(?<be>be blocked)|block)\.?\z/

        def self.parse(line)
          new(method: $~[:be] ? "can_be_blocked?" : "can_block?") if LINE.match(line)
        end

        def kinds = %i[creature]
        def body_source = "def #{method}(_) = false\n"
      end
    end
  end
end
