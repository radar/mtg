# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Tap target creature." / "Tap target creature an opponent controls." /
      # "Tap enchanted creature." / "Tap it." (an earlier target)
      class TapTarget < Data.define(:reference)
        include Effect

        LINE = /\ATap (?:(?<this>~)|#{PermanentTarget::REFERENCE})\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          # "Tap ~." (also what "Tap it." means in an ability that targets nothing).
          return new(reference: PermanentTarget::Reference.new(choices: nil, object: Effect::THIS)) if m[:this]

          new(reference: PermanentTarget.reference(m))
        end

        def target_choices = reference.choices
        def earlier_target? = reference.earlier_target?
        def resolve_call = "trigger_effect(:tap, target: #{reference.object})"
      end
    end
  end
end
