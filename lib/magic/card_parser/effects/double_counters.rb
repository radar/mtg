# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Double the number of +1/+1 counters on ~." / "... on enchanted creature." /
      # "... on each creature you control." Adds as many counters as it already has.
      class DoubleCounters < Data.define(:counter_type, :who, :targets)
        include Effect

        LINE = %r{\ADouble the number of (?<type>[+-]1/[+-]1|[a-z]+) counters on (?:(?<self>~)|(?<attached>enchanted|equipped) creature|(?<each>#{AddCounters::EACH}))\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))

          Magic::Counters[m[:type].downcase] # raises for an unknown counter type
          who, targets = if m[:self] then [:self, THIS]
                         elsif m[:attached] then [:self, "#{THIS}.attached_to"]
                         else [:each, AddCounters.each_targets(m)]
                         end
          new(counter_type: m[:type], who:, targets:)
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        def resolve_call
          type = "Counters[#{counter_type.inspect}]"
          if who == :self
            "trigger_effect(:add_counter, counter_type: #{counter_type.inspect}, target: #{targets}, amount: #{targets}.counters.of_type(#{type}).count)"
          else
            "#{targets}.each { trigger_effect(:add_counter, counter_type: #{counter_type.inspect}, target: _1, amount: _1.counters.of_type(#{type}).count) }"
          end
        end
      end
    end
  end
end
