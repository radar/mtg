# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "~ deals 3 damage to any target." / "~ deals 1 damage to each opponent."
      class DealDamage < Data.define(:amount, :targets)
        include Effect

        LINE = /\A(?:~|It) deals (?<amount>\d+|\w+) damage to (?<targets>[\w ]+?)\.?\z/
        TARGETS = {
          "any target" => "game.any_target",
          "target creature" => "battlefield.creatures",
          "target player" => "game.players",
          "target creature or planeswalker" => "battlefield.creatures + battlefield.planeswalkers"
        }.freeze
        # Not targeted: who is dealt damage -> Ruby for the recipients.
        UNTARGETED = {
          "each opponent" => "game.opponents(controller)",
          "you" => "[controller]",
          "each player" => "game.players",
          "each creature" => "battlefield.creatures",
          "each creature and each player" => "(battlefield.creatures + game.players)"
        }.freeze

        def self.parse(text)
          return unless (m = LINE.match(text)) && (TARGETS.key?(m[:targets]) || UNTARGETED.key?(m[:targets]) || creature_target(m[:targets]))

          new(amount: Number.parse(m[:amount]), targets: m[:targets])
        end

        # "target tapped creature", "target creature with flying": a creature qualified the
        # way PermanentTarget knows.
        def self.creature_target(text)
          match = /\A#{PermanentTarget::PATTERN}\z/.match(text)
          match if match && PermanentTarget.creature?(match) && !match[:up_to]
        end

        def target_choices
          TARGETS[targets] || ((match = self.class.creature_target(targets)) && PermanentTarget.choices(match))
        end

        def resolve_call
          return "#{UNTARGETED[targets]}.each { trigger_effect(:deal_damage, target: _1, damage: #{amount}) }" if UNTARGETED.key?(targets)

          "trigger_effect(:deal_damage, target: target, damage: #{amount})"
        end
      end
    end
  end
end
