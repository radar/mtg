# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ enters with two +1/+1 counters on it." / "~ enters with three time
      # counters on it." (older: "enters the battlefield with")
      class EntersWithCounters < Data.define(:amount, :counter_type)
        include Rule

        LINE = %r{\A~ enters(?: the battlefield)? with (?<amount>\d+|\w+) (?<type>[\w+/-]+) counters? on it\.?\z}

        def self.parse(line)
          return unless (m = LINE.match(line))

          type = m[:type].downcase
          Magic::Counters[type]
          new(amount: Number.parse(m[:amount]), counter_type: type)
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        # +1/+1 counters only mean something on creatures.
        def kinds = counter_type == "+1/+1" ? %i[creature] : PERMANENT_KINDS
        def body_source = "enters_with_counters #{counter_type.inspect}, #{amount}\n"
      end
    end
  end
end
