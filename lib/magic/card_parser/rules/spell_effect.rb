# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # The rules text of an instant or sorcery: one effect sentence.
      # Generates target_choices (when targeted) and resolve!.
      class SpellEffect < Data.define(:effect)
        include Rule

        def self.parse(line)
          effect = Effect.parse(line)
          new(effect:) if effect
        end

        def kinds = %i[instant sorcery]

        def body_source
          [effect.definitions, resolve_source].compact.join("\n")
        end

        private

        def resolve_source
          return "def resolve!\n  #{effect.resolve_call}\nend\n" unless effect.target_choices

          <<~RUBY
            def target_choices
              #{effect.target_choices}
            end

            def resolve!(target:)
              #{effect.resolve_call}
            end
          RUBY
        end
      end
    end
  end
end
