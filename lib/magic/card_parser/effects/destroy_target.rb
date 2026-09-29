# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Destroy target creature." / "Destroy target artifact an opponent controls."
      class DestroyTarget < Data.define(:targets, :optional)
        include Effect

        def initialize(targets:, optional: false) = super

        LINE = /\ADestroy #{PermanentTarget::PATTERN}\.?\z/i

        def self.parse(text)
          new(targets: PermanentTarget.choices($~), optional: PermanentTarget.optional?($~)) if LINE.match(text)
        end

        def target_choices = targets
        def optional_target? = optional
        def resolve_call = "trigger_effect(:destroy_target, target: target)"
      end
    end
  end
end
