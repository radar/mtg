# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Scry 1." Scry is a player choice, so the effects after it in the same
      # spell run when that choice resolves (see Rules::SpellEffect).
      class Scry < Data.define(:amount)
        include Effect

        LINE = /\AScry (?<amount>\d+|\w+)\.?\z/i

        def self.parse(text)
          new(amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def choice_base = "Magic::Choice::Scry"
        def choice_class_name = "ScryChoice"
        def choice_args = "amount: #{amount}"
      end
    end
  end
end
