# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "~ deals X damage to target creature. Create a number of 1/1 red Goblin creature tokens equal to the
      # amount of excess damage dealt to that creature this way." (Goblin Negotiation). X is the spell's X
      # (`value_for_x`). Excess is the damage actually marked beyond what was lethal before the hit (so
      # prevented damage doesn't count), measured from the creature's marked damage and toughness.
      class DamageThenTokensForExcess < Data.define(:token)
        include Effect

        LINE = /\A~ deals X damage to target creature\. Create a number of (?<token>\d+\/\d+ [a-z]+(?: and [a-z]+)? [A-Z][\w ]*? creature tokens?) equal to the amount of excess damage dealt to that creature this way\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          token = CreateToken.parse("Create a #{m[:token]}") or return
          new(token:)
        end

        def target_choices = "battlefield.creatures"
        def definitions = token.definitions
        # The spell's `resolve!` takes `value_for_x:` (see EffectList#spell_source).
        def uses_x? = true

        def resolve_call
          <<~RUBY.chomp
            lethal = [target.toughness - target.damage, 0].max
            marked = target.damage
            trigger_effect(:deal_damage, target: target, damage: value_for_x)
            excess = [(target.damage - marked) - lethal, 0].max
            #{token.with(amount: 'excess').resolve_call}
          RUBY
        end
      end
    end
  end
end
