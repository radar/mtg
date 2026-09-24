# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Untap target creature." / "Untap it." / "Untap that creature." (an earlier target)
      class UntapTarget < Data.define(:reference)
        include Effect

        LINE = /\AUntap #{PermanentTarget::REFERENCE}\.?\z/i

        def self.parse(text)
          new(reference: PermanentTarget.reference($~)) if LINE.match(text)
        end

        def target_choices = reference.choices
        def earlier_target? = reference.earlier_target?
        def resolve_call = "#{reference.object}.untap!"
      end
    end
  end
end
