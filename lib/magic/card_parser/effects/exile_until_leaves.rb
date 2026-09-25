# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Exile [up to one] target nonland permanent an opponent controls until ~ leaves
      # the battlefield." (Permanent#exile_until_leaves!)
      class ExileUntilLeaves < Data.define(:reference)
        include Effect

        LINE = /\AExile #{PermanentTarget::PATTERN} until ~ leaves the battlefield\.?\z/i

        def self.parse(text)
          new(reference: PermanentTarget.reference($~)) if LINE.match(text)
        end

        def target_choices = reference.choices
        def optional_target? = reference.optional
        def resolve_call = "#{THIS}.exile_until_leaves!(target)"
      end
    end
  end
end
