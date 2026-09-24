# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Surveil 2." Surveil is a player choice, so the effects after it in the same
      # spell run when that choice resolves (see Rules::SpellEffect).
      class Surveil < Data.define(:amount)
        include Effect

        LINE = /\ASurveil (?<amount>\d+|\w+)\.?\z/i

        def self.parse(text)
          new(amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def choice_base = "Magic::Choice::Surveil"
        def choice_class_name = "SurveilChoice"
        def choice_args = "amount: #{amount}"
      end
    end
  end
end
