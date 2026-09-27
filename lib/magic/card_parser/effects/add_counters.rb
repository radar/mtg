# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Put a +1/+1 counter on target creature." / "Put two +1/+1 counters on
      # each creature you control." / "Put a +1/+1 counter on ~." / "Put a quest counter
      # on ~." / "Put a stun counter on target creature." (any counter type
      # Magic::Counters knows can go on a target or ~ -- self was once the only place a
      # non-+1/+1-or--1/-1 counter type was allowed; loosened for "stun", which the same
      # way real cards print it).
      class AddCounters < Data.define(:amount, :counter_type, :who, :targets, :optional, :earlier)
        include Effect

        # The target alternative is PermanentTarget::REFERENCE (not just PATTERN), so
        # "put a counter on it" ("it" = whatever an earlier effect in the same ability
        # targeted, e.g. "Tap target creature. Put a stun counter on it.") works too, via
        # #earlier_target? -- see PermanentTarget::Reference.
        LINE = %r{\APut (?<amount>\d+|\w+) (?<type>[+-]1/[+-]1|[a-z]+) counters? on (?:(?<self>~)|(?<each>each creature you control)|#{PermanentTarget::REFERENCE})\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return if m[:kind] && !PermanentTarget.creature?(m)

          Magic::Counters[m[:type].downcase] # raises for an unknown counter type

          who, targets, optional, earlier = if m[:self] then [:self, nil, false, false]
                                             elsif m[:each] then [:each, "battlefield.controlled_by(controller).creatures", false, false]
                                             else
                                               reference = PermanentTarget.reference(m)
                                               [:target, reference.choices, reference.optional, reference.earlier_target?]
                                             end
          new(amount: Number.parse(m[:amount]), counter_type: m[:type], who:, targets:, optional:, earlier:)
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        def target_choices = who == :target ? targets : nil
        def optional_target? = optional
        def earlier_target? = earlier

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
