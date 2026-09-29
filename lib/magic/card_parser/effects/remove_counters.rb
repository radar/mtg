# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Remove a time counter from ~." Does nothing if ~ has too few. "Remove all charge
      # counters from ~." removes however many it has.
      class RemoveCounters < Data.define(:amount, :counter)
        include Effect

        LINE = %r{\ARemove (?<amount>all|\d+|\w+) (?<type>[\w+/-]+) counters? from ~\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))

          counter = Magic::Counters[m[:type].downcase].name.split("::").last
          new(amount: m[:amount].casecmp?("all") ? :all : Number.parse(m[:amount]), counter: "Counters::#{counter}")
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        def resolve_call
          counters = "#{THIS}.counters.of_type(#{counter})"
          return "trigger_effect(:remove_counter, counter_type: #{counter}, target: #{THIS}, amount: #{counters}.count) if #{counters}.any?" if amount == :all

          "trigger_effect(:remove_counter, counter_type: #{counter}, target: #{THIS}, amount: #{amount}) " \
            "if #{counters}.count >= #{amount}"
        end
      end
    end
  end
end
