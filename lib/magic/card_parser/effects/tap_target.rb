# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Tap target creature." / "Tap target creature an opponent controls."
      class TapTarget < Data.define(:targets)
        include Effect

        LINE = /\ATap #{PermanentTarget::PATTERN}\.?\z/i

        def self.parse(text)
          new(targets: PermanentTarget.choices($~)) if LINE.match(text)
        end

        def target_choices = targets
        def resolve_call = "trigger_effect(:tap, target: target)"
      end
    end
  end
end
