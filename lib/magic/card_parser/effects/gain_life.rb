# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "You gain 3 life."
      class GainLife < Data.define(:amount)
        include Effect

        LINE = /\A(?:You )?gain (?<amount>\d+|\w+) life\.?\z/i

        def self.parse(text)
          new(amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def resolve_call = "gain_life #{amount}"
      end
    end
  end
end
