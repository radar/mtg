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

        # "each [other] [<Type>] creature [you control / an opponent controls / each opponent controls]"
        EACH_CONTROLLERS = {
          nil => "battlefield",
          "you control" => "battlefield.controlled_by(controller)",
          "an opponent controls" => "battlefield.not_controlled_by(controller)",
          "each opponent controls" => "battlefield.not_controlled_by(controller)"
        }.freeze
        EACH = /each (?<other>other )?(?:(?<etype>(?-i:#{PermanentTarget::CREATURE_TYPES})) )?creature(?: (?<ewho>#{EACH_CONTROLLERS.keys.compact.join('|')}))?/

        # The target alternative is PermanentTarget::REFERENCE (not just PATTERN), so
        # "put a counter on it" ("it" = whatever an earlier effect in the same ability
        # targeted, e.g. "Tap target creature. Put a stun counter on it.") works too, via
        # #earlier_target? -- see PermanentTarget::Reference. "... for each <Count>" scales
        # the amount.
        LINE = %r{\APut (?<amount>\d+|\w+) (?<type>[+-]1/[+-]1|[a-z]+) counters? on (?:(?<self>~)|(?<each>#{EACH})|#{PermanentTarget::REFERENCE})(?: for each (?<per>[^.]+?))?\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))
          # +1/+1 and -1/-1 counters only mean something on creatures; a named counter can go on any permanent.
          return if m[:kind] && !PermanentTarget.creature?(m) && m[:type].match?(%r{\A[+-]1/[+-]1\z})

          Magic::Counters[m[:type].downcase] # raises for an unknown counter type
          amount = Number.parse(m[:amount])
          if m[:per]
            return unless (count = Count.parse(m[:per], this: THIS))

            amount = "#{amount} * #{count}"
          end

          who, targets, optional, earlier = if m[:self] then [:self, nil, false, false]
                                             elsif m[:each] then [:each, each_targets(m), false, false]
                                             else
                                               reference = PermanentTarget.reference(m)
                                               [:target, reference.choices, reference.optional, reference.earlier_target?]
                                             end
          new(amount:, counter_type: m[:type], who:, targets:, optional:, earlier:)
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        def self.each_targets(match)
          creatures = "#{EACH_CONTROLLERS.fetch(match[:ewho]&.downcase)}.creatures"
          creatures += ".by_any_type(#{match[:etype].inspect})" if match[:etype]
          match[:other] ? "(#{creatures} - [#{THIS}])" : creatures
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
