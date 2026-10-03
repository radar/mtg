# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Put a +1/+1 counter on each of up to two other target creatures you control." Several
      # targets chosen on resolution (a triggered ability): its TargetChoice has
      # `choice_amount = 0..N` and `resolve!(targets:)`, and is never chosen for you
      # (`optional_target?`), since choosing fewer than N is always allowed.
      class CountersOnUpToTargets < Data.define(:counters, :max_targets, :reference)
        include Effect

        LINE = /\APut (?<list>#{AddCounters::LIST}) on each of up to (?<count>\w+) (?<another>other )?target (?<kind>creatures|artifacts|lands)(?: (?<controller>you control|an opponent controls))?\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          items = m[:list].split(/,? and |, /).map { AddCounters::ITEM_PARTS.match(_1) }
          items.each { Magic::Counters[_1[:type].downcase] }
          reference = PermanentTarget::PATTERN.match("#{m[:another] ? 'another ' : ''}target #{m[:kind].downcase.delete_suffix('s')} #{m[:controller]}".strip)
          new(counters: items.map { [Number.parse(_1[:amount]), _1[:type]] }, max_targets: Number.parse(m[:count]), reference:)
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        def target_choices = PermanentTarget.choices(reference)
        def optional_target? = true

        def resolve_call
          adds = counters.map { |amount, type| "trigger_effect(:add_counter, counter_type: #{type.inspect}, target: _1, amount: #{amount})" }
          "targets.each { #{adds.join('; ')} }"
        end
      end
    end
  end
end
