# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Up to one target creature gains all creature types." (The effect doesn't end.)
      class GainAllCreatureTypes < Data.define(:reference)
        include Effect

        LINE = /\A#{PermanentTarget::REFERENCE} gains all creature types\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return if m[:kind] && !PermanentTarget.creature?(m)

          new(reference: PermanentTarget.reference(m))
        end

        def target_choices = reference.choices
        def optional_target? = !!reference.optional
        def earlier_target? = !!reference.earlier_target?
        def resolve_call = "#{reference.object}.gain_all_creature_types!"
      end
    end
  end
end
