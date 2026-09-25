# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Discard two cards unless you discard a creature card." (also "Then discard ...").
      # The discard is a player choice (Choice::DiscardUnless), so the effects after it run
      # when that choice resolves.
      class DiscardUnless < Data.define(:amount, :card_type)
        include Effect

        LINE = /\A(?:Then )?discard (?<amount>\d+|\w+) cards? unless you discard an? (?<type>[a-z-]+) card\.?\z/i

        def self.parse(text)
          new(amount: Number.parse($~[:amount]), card_type: $~[:type].capitalize) if LINE.match(text)
        end

        def choice_base = "Magic::Choice::DiscardUnless"
        def choice_class_name = "DiscardUnlessChoice"
        def choice_args = ["amount: #{amount}", "card_type: #{card_type.inspect}"]
      end
    end
  end
end
