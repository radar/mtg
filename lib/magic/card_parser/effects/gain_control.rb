# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Gain control of target creature until end of turn." / "Gain control of
      # target artifact." (for good)
      class GainControl < Data.define(:targets, :until_eot)
        include Effect

        LINE = /\AGain control of #{PermanentTarget::PATTERN}(?<until_eot> until end of turn)?\.?\z/i

        def self.parse(text)
          new(targets: PermanentTarget.choices($~), until_eot: !$~[:until_eot].nil?) if LINE.match(text)
        end

        def target_choices = targets

        def resolve_call
          until_eot ? "target.gain_control_until_eot!(controller)" : "target.controller = controller"
        end
      end
    end
  end
end
