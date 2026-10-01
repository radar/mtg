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
      #
      # Several kinds at once ("Put two +1/+1 counters and a reach counter on target creature.",
      # "a flying counter, a deathtouch counter, and a lifelink counter") are one effect with
      # several `counters` ([amount, type] pairs), each added in turn.
      class AddCounters < Data.define(:counters, :who, :targets, :optional, :earlier)
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
        ITEM = %r{(?:\d+|\w+) (?:[+-]1/[+-]1|[a-z]+) counters?}i
        ITEM_PARTS = %r{\A(?<amount>\d+|\w+) (?<type>[+-]1/[+-]1|[a-z]+) counters?\z}i
        LIST = /#{ITEM}(?:, #{ITEM})*(?:,? and #{ITEM})?/
        LINE = %r{\APut (?<list>#{LIST}) on (?:(?<self>~)|(?<each>#{EACH})|#{PermanentTarget::REFERENCE})(?: for each (?<per>[^.]+?))?\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))

          items = m[:list].split(/,? and |, /).map { ITEM_PARTS.match(_1) }
          return if m[:per] && items.size > 1

          # +1/+1 and -1/-1 counters only mean something on creatures; a named counter can go on any permanent.
          return if m[:kind] && !PermanentTarget.creature?(m) && items.any? { _1[:type].match?(%r{\A[+-]1/[+-]1\z}) }

          items.each { Magic::Counters[_1[:type].downcase] } # raises for an unknown counter type
          counters = items.map { [Number.parse(_1[:amount]), _1[:type]] }
          if m[:per]
            return unless (count = Count.parse(m[:per], this: THIS))

            counters = [["#{counters.first.first} * #{count}", counters.first.last]]
          end

          who, targets, optional, earlier = if m[:self] then [:self, nil, false, false]
                                             elsif m[:each] then [:each, each_targets(m), false, false]
                                             else
                                               reference = PermanentTarget.reference(m)
                                               [:target, reference.choices, reference.optional, reference.earlier_target?]
                                             end
          new(counters:, who:, targets:, optional:, earlier:)
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

        def add(target)
          counters.map { |amount, type| "trigger_effect(:add_counter, counter_type: #{type.inspect}, target: #{target}, amount: #{amount})" }.join("\n")
        end
      end
    end
  end
end
