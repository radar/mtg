# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "~ deals 2 damage to any target and 1 damage to any other target." A spell with two
      # targets, chosen on casting (`multi_target?`, `resolve!(targets:)`); the second must differ
      # from the first (`distinct_targets?`). Only instants and sorceries: see EffectList#spell_source.
      class DealDamageTwoTargets < Data.define(:first_amount, :second_amount)
        include Effect

        LINE = /\A(?:~|It) deals (?<first>\d+|\w+) damage to any target and (?<second>\d+|\w+) damage to any other target\.?\z/

        def self.parse(text)
          new(first_amount: Number.parse($~[:first]), second_amount: Number.parse($~[:second])) if LINE.match(text)
        end

        def multi_target? = true
        def distinct_targets? = true
        def target_choices = "[game.any_target, game.any_target]"

        def resolve_call
          <<~RUBY.chomp
            first, second = targets
            deal_damage #{first_amount}, to: first
            deal_damage #{second_amount}, to: second
          RUBY
        end
      end
    end
  end
end
