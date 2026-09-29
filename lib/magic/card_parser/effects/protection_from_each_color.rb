# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target creature you control gains protection from each color until your next turn."
      class ProtectionFromEachColor < Data.define(:reference)
        include Effect

        LINE = /\A#{PermanentTarget::REFERENCE} gains protection from each color until your next turn\.?\z/i

        def self.parse(text)
          new(reference: PermanentTarget.reference($~)) if LINE.match(text)
        end

        def target_choices = reference.choices
        def earlier_target? = !!reference.earlier_target?
        def resolve_call = "#{reference.object}.gains_protection_from_each_color_until_turn_of!(controller)"
      end
    end
  end
end
