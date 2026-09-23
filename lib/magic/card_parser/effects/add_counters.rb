# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Put a +1/+1 counter on target creature." / "Put two +1/+1 counters on
      # each creature you control."
      class AddCounters < Data.define(:amount, :counter_type, :targets, :each)
        include Effect

        LINE = %r{\APut (?<amount>\d+|\w+) (?<type>[+-]1/[+-]1) counters? on (?:(?<each>each creature you control)|#{PermanentTarget::PATTERN})\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return if m[:kind] && m[:kind].downcase != "creature"

          targets = m[:each] ? "battlefield.controlled_by(controller).creatures" : PermanentTarget.choices(m)
          new(amount: Number.parse(m[:amount]), counter_type: m[:type], targets:, each: !m[:each].nil?)
        end

        def target_choices = each ? nil : targets

        def resolve_call
          add = ->(target) { "trigger_effect(:add_counter, counter_type: #{counter_type.inspect}, target: #{target}, amount: #{amount})" }
          each ? "#{targets}.each { #{add.('_1')} }" : add.("target")
        end
      end
    end
  end
end
