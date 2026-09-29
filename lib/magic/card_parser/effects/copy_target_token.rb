# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create a token that's a copy of target Kithkin you control."
      class CopyTargetToken < Data.define(:targets)
        include Effect

        LINE = /\ACreate a token that's a copy of #{PermanentTarget::PATTERN}\.?\z/i

        def self.parse(text)
          new(targets: PermanentTarget.choices($~)) if LINE.match(text)
        end

        def target_choices = targets

        def resolve_call
          "Permanent.resolve(game: game, owner: controller, card: target.copiable_card, token: true, copy: true, cast: false)"
        end
      end
    end
  end
end
