# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ enters with two +1/+1 counters on it." / "~ enters with three time
      # counters on it." (older: "enters the battlefield with") / "~ enters with X +1/+1
      # counters on it, where X is the greatest power among other creatures you control."
      # (a count: the amount is Ruby, worked out as the card enters).
      class EntersWithCounters < Data.define(:amount, :counter_type)
        include Rule

        LINE = %r{\A~ enters(?: the battlefield)? with (?<amount>\d+|\w+) (?<type>[\w+/-]+) counters? on it(?:, where X is (?<where>[^.]+))?\.?\z}

        def self.parse(line)
          return unless (m = LINE.match(line))

          type = m[:type].downcase
          Magic::Counters[type]
          if m[:where]
            return unless m[:amount] == "X" && (count = Count.parse(m[:where], this: "self"))

            return new(amount: count, counter_type: type)
          end
          new(amount: Number.parse(m[:amount]), counter_type: type)
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        # +1/+1 counters only mean something on creatures.
        def kinds = counter_type == "+1/+1" ? %i[creature] : PERMANENT_KINDS

        def body_source
          return "enters_with_counters #{counter_type.inspect}, #{amount}\n" if amount.is_a?(Integer)

          # A card in hand has no controller yet; the one casting it is the owner (or its controller on the stack).
          "def entering_counters\n  controller = self.controller || owner\n  { #{counter_type.inspect} => #{amount} }\nend\n"
        end
      end
    end
  end
end
