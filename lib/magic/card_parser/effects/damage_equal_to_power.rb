# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "It deals damage equal to its power to target creature or planeswalker." / "~ deals damage equal to its power to
      # any target." (Heartfire Immolator, after "Sacrifice ~"). The damage uses the permanent's power as it last was:
      # a sacrificed creature's `power` is still readable.
      class DamageEqualToPower < Data.define(:targets)
        include Effect

        LINE = /\A(?:~|It) deals damage equal to its power to (?<targets>#{DealDamage::TARGETS.keys.join('|')})\.?\z/

        def self.parse(text)
          new(targets: $~[:targets]) if LINE.match(text)
        end

        def target_choices = DealDamage::TARGETS.fetch(targets)

        def resolve_call
          "trigger_effect(:deal_damage, source: #{Effect::THIS}, target: target, damage: #{Effect::THIS}.power)"
        end
      end
    end
  end
end
