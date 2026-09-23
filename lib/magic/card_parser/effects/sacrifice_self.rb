# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Sacrifice ~." / "Sacrifice it." (in an ability of ~)
      class SacrificeSelf < Data.define
        include Effect

        LINE = /\ASacrifice (?:~|it)\.?\z/i

        def self.parse(text)
          new if LINE.match?(text)
        end

        def resolve_call = "trigger_effect(:sacrifice, target: #{THIS})"
      end
    end
  end
end
