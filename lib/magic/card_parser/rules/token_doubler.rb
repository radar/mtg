# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "If an effect would create one or more tokens under your control, it creates
      # twice that many of those tokens instead." (Anointed Procession, Parallel Lives)
      class TokenDoubler < Data.define
        include Rule

        LINE = /\AIf an effect would create one or more tokens under your control, it creates twice that many of those tokens instead\.?\z/

        def self.parse(line)
          new if LINE.match?(line)
        end

        def kinds = PERMANENT_KINDS

        def body_source
          <<~RUBY
            def replacement_effects = { Effects::CreateToken => ReplacementEffect::TokenDoubler }
          RUBY
        end
      end
    end
  end
end
