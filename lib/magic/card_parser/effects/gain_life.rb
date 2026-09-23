# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "You gain 3 life."
      class GainLife < Data.define(:amount)
        include Effect

        LINE = /\AYou gain (?<amount>\d+|\w+) life\.?\z/i

        def self.parse(text)
          new(amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def resolve_call = "trigger_effect(:gain_life, target: controller, life: #{amount})"
      end
    end
  end
end
