# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "If target player has exactly 10 life, ~ deals 10 damage to that player." (Hidetsugu's Second Rite). The
      # life total is checked as the spell resolves; the player is the spell's target.
      class DamageIfExactLife < Data.define(:life, :damage)
        include Effect

        LINE = /\AIf target player has exactly (?<life>\d+) life, ~ deals (?<damage>\d+|\w+) damage to that player\.?\z/i

        def self.parse(text)
          new(life: $~[:life].to_i, damage: Number.parse($~[:damage])) if LINE.match(text)
        end

        def target_choices = "game.players"

        def resolve_call
          "trigger_effect(:deal_damage, target: target, damage: #{damage}) if target.life == #{life}"
        end
      end
    end
  end
end
