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
            class TokenDoubler < ReplacementEffect
              def applies?(effect)
                effect.controller == receiver.controller
              end

              def call(effect)
                Effects::CreateToken.new(
                  source: receiver,
                  token_class: effect.token_class,
                  controller: receiver.controller,
                  amount: effect.amount * 2,
                )
              end
            end

            def replacement_effects = { Effects::CreateToken => TokenDoubler }
          RUBY
        end
      end
    end
  end
end
