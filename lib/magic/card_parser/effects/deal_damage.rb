# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "~ deals 3 damage to any target."
      class DealDamage < Data.define(:amount, :targets)
        include Effect

        LINE = /\A(?:~|It) deals (?<amount>\d+|\w+) damage to (?<targets>[\w ]+?)\.?\z/
        TARGETS = {
          "any target" => "game.any_target",
          "target creature" => "battlefield.creatures",
          "target player" => "game.players",
          "target creature or planeswalker" => "battlefield.creatures + battlefield.planeswalkers"
        }.freeze

        def self.parse(text)
          return unless (m = LINE.match(text)) && TARGETS.key?(m[:targets])

          new(amount: Number.parse(m[:amount]), targets: m[:targets])
        end

        def target_choices = TARGETS.fetch(targets)
        def resolve_call = "trigger_effect(:deal_damage, target: target, damage: #{amount})"
      end
    end
  end
end
