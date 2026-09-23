# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ enters with two +1/+1 counters on it." (older: "enters the battlefield with")
      class EntersWithCounters < Data.define(:amount)
        include Rule

        LINE = %r{\A~ enters(?: the battlefield)? with (?<amount>\d+|\w+) \+1/\+1 counters? on it\.?\z}

        def self.parse(line)
          new(amount: Number.parse($~[:amount])) if LINE.match(line)
        end

        def kinds = %i[creature]
        def body_source = "enters_with_counters \"+1/+1\", #{amount}\n"
      end
    end
  end
end
