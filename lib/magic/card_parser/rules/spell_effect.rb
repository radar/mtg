# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # The rules text of an instant or sorcery: one effect per line, in order.
      # Generates target_choices (when targeted) and resolve!. An effect that adds
      # a choice (scry) gets a Choice subclass, and the effects after it resolve
      # there, once the player has chosen.
      class SpellEffect < Data.define(:effects)
        include Rule

        def self.parse(line)
          effect = Effect.parse(line)
          new(effects: [effect]) if effect
        end

        def self.merge(rules) = [new(effects: rules.flat_map(&:effects))]

        def kinds = %i[instant sorcery]

        def body_source
          targeted = effects.select(&:target_choices)
          raise UnsupportedCard, "only one targeted effect per spell is supported" if targeted.size > 1

          index = effects.index(&:choice_base) || effects.size
          now = effects[..index]
          later = effects[(index + 1)..]
          [*choice_class(effects[index], later), resolve_source(now, targeted.first)].join("\n")
        end

        private

        # The choice's subclass runs the effects that come after it.
        def choice_class(choice, later)
          return [] unless choice
          raise UnsupportedCard, "only one choice per spell is supported" if later.any?(&:choice_base)
          raise UnsupportedCard, "targeted effects after a choice are not supported" if later.any?(&:target_choices)

          <<~RUBY
            class #{choice.choice_class_name} < #{choice.choice_base}
              def resolve!(**args)
                super(**args)
            #{later.map { "    #{_1.resolve_call}\n" }.join}  end
            end
          RUBY
        end

        def resolve_source(now, targeted)
          calls = now.map { "  #{_1.resolve_call}\n" }.join
          return "def resolve!\n#{calls}end\n" unless targeted

          <<~RUBY
            def target_choices
              #{targeted.target_choices}
            end

            def resolve!(target:)
            #{calls}end
          RUBY
        end
      end
    end
  end
end
