# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Exile target creature." / "Exile target enchantment an opponent controls."
      class ExileTarget < Data.define(:targets)
        include Effect

        LINE = /\AExile #{PermanentTarget::PATTERN}\.?\z/i

        def self.parse(text)
          new(targets: PermanentTarget.choices($~)) if LINE.match(text)
        end

        def target_choices = targets
        def resolve_call = "trigger_effect(:exile, target: target)"
      end
    end
  end
end
