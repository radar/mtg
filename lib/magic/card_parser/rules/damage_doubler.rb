# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "If a creature you control would deal damage to a permanent or player, it deals double that damage instead."
      # (Gratuitous Violence) / "If a source you control would deal damage to an opponent or a permanent an opponent
      # controls, it deals double that damage instead." (Twinflame Tyrant) -> a `ReplacementEffect::DamageDoubler`
      # subclass registered on both damage effects.
      class DamageDoubler < Data.define(:replacement)
        include Rule

        LINES = {
          /\AIf a creature you control would deal damage to a permanent or player, it deals double that damage instead\.?\z/ => "CreatureDamageDoubler",
          /\AIf a source you control would deal damage to an opponent or a permanent an opponent controls, it deals double that damage instead\.?\z/ => "OpponentDamageDoubler"
        }.freeze

        def self.parse(line)
          LINES.each { |pattern, replacement| return new(replacement:) if pattern.match?(line) }
          nil
        end

        def kinds = PERMANENT_KINDS

        def body_source = "def replacement_effects = ReplacementEffect::#{replacement}.registrations\n"
      end
    end
  end
end
