# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Return target creature to its owner's hand." / "Return target nonland
      # permanent an opponent controls to its owner's hand."
      class Bounce < Data.define(:targets)
        include Effect

        LINE = /\AReturn #{PermanentTarget::PATTERN} to its owner's hand\.?\z/i

        def self.parse(text)
          new(targets: PermanentTarget.choices($~)) if LINE.match(text)
        end

        def target_choices = targets
        def resolve_call = "trigger_effect(:return_to_owners_hand, target: target)"
      end
    end
  end
end
