# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create two 1/1 blue Faerie creature tokens with flying. When you do, tap target creature an opponent
      # controls." (Faebloom Trick). The tap is a reflexive trigger, so its target is chosen as the effect
      # resolves (a `TapChoice`, skipped when there is nothing to tap), not when the spell is cast.
      class TokensThenTap < Data.define(:token, :tap)
        include Effect

        LINE = /\A(?<create>Create [^.]+)\. When you do, (?<tap>tap target [^.]+)\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          token = CreateToken.parse(m[:create]) or return
          tap = TapTarget.parse(m[:tap]) or return
          new(token:, tap:) if tap.target_choices && !tap.earlier_target?
        end

        def definitions
          [token.definitions, <<~RUBY].join("\n")
            class TapChoice < Magic::Choice::Targeted
              def choices
                #{tap.target_choices}
              end

              def choice_amount = 1

              def resolve!(target:)
                #{tap.resolve_call}
              end
            end
          RUBY
        end

        def resolve_call
          "#{token.resolve_call}\nchoice = TapChoice.new(actor: #{THIS})\ngame.add_choice(choice) if choice.choices.any?"
        end
      end
    end
  end
end
