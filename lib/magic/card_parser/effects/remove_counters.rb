# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Remove a time counter from ~." Does nothing if ~ has too few.
      class RemoveCounters < Data.define(:amount, :counter)
        include Effect

        LINE = %r{\ARemove (?<amount>\d+|\w+) (?<type>[\w+/-]+) counters? from ~\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))

          counter = Magic::Counters[m[:type].downcase].name.split("::").last
          new(amount: Number.parse(m[:amount]), counter: "Counters::#{counter}")
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        def resolve_call
          "trigger_effect(:remove_counter, counter_type: #{counter}, target: #{THIS}, amount: #{amount}) " \
            "if #{THIS}.counters.of_type(#{counter}).count >= #{amount}"
        end
      end
    end
  end
end
