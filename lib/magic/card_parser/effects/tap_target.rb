# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Tap target creature." / "Tap target creature an opponent controls." /
      # "Tap enchanted creature." / "Tap it." (an earlier target)
      class TapTarget < Data.define(:reference)
        include Effect

        LINE = /\ATap #{PermanentTarget::REFERENCE}\.?\z/i

        def self.parse(text)
          new(reference: PermanentTarget.reference($~)) if LINE.match(text)
        end

        def target_choices = reference.choices
        def earlier_target? = reference.earlier_target?
        def resolve_call = "trigger_effect(:tap, target: #{reference.object})"
      end
    end
  end
end
