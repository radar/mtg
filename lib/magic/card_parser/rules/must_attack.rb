# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ attacks each combat if able." -> `def must_attack? = true`, which `CombatPhase#validate_attackers!`
      # checks when attackers are declared (a creature that could attack but isn't raises `IllegalAttack`).
      class MustAttack < Data.define
        include Rule

        LINE = /\A~ attacks each combat if able\.?\z/i

        def self.parse(line)
          new if LINE.match?(line)
        end

        def kinds = %i[creature]

        def body_source = "def must_attack? = true\n"
      end
    end
  end
end
