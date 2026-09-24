# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Put a +1/+1 counter on target creature." / "Put two +1/+1 counters on
      # each creature you control." / "Put a +1/+1 counter on ~." / "Put a quest counter
      # on ~." (a counter type Magic::Counters knows; only +1/+1 can go on other permanents).
      class AddCounters < Data.define(:amount, :counter_type, :who, :targets)
        include Effect

        LINE = %r{\APut (?<amount>\d+|\w+) (?<type>[+-]1/[+-]1|[a-z]+) counters? on (?:(?<self>~)|(?<each>each creature you control)|#{PermanentTarget::PATTERN})\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return if m[:kind] && !PermanentTarget.creature?(m)
          return unless m[:type].match?(%r{\A[+-]1/[+-]1\z}) || m[:self]

          Magic::Counters[m[:type].downcase] # raises for an unknown counter type

          who, targets = if m[:self] then [:self, nil]
                         elsif m[:each] then [:each, "battlefield.controlled_by(controller).creatures"]
                         else [:target, PermanentTarget.choices(m)]
                         end
          new(amount: Number.parse(m[:amount]), counter_type: m[:type], who:, targets:)
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        def target_choices = who == :target ? targets : nil

        def resolve_call
          case who
          when :self then add(THIS)
          when :each then "#{targets}.each { #{add('_1')} }"
          else add("target")
          end
        end

        private

        def add(target) = "trigger_effect(:add_counter, counter_type: #{counter_type.inspect}, target: #{target}, amount: #{amount})"
      end
    end
  end
end
