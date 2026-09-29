# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Exile target creature." / "Exile target enchantment an opponent controls."
      class ExileTarget < Data.define(:targets, :optional)
        include Effect

        def initialize(targets:, optional: false) = super

        LINE = /\AExile #{PermanentTarget::PATTERN}\.?\z/i

        def self.parse(text)
          new(targets: PermanentTarget.choices($~), optional: PermanentTarget.optional?($~)) if LINE.match(text)
        end

        def target_choices = targets
        def optional_target? = optional
        def resolve_call = "trigger_effect(:exile, target: target)"
      end
    end
  end
end
