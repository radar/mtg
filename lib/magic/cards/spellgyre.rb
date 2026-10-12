module Magic
  module Cards
    Spellgyre = Instant("Spellgyre") do
      cost generic: 2, blue: 2
    end

    class Spellgyre < Instant
      class Mode1 < Mode
        def target_choices
          game.stack.spells
        end

        def resolve!(target:)
          trigger_effect(:counter_spell, target: target)
        end
      end

      class Mode2 < Mode
        class SurveilChoice < Magic::Choice::Surveil
          def resolve!(**args)
            super(**args)
            draw_cards(2)
          end
        end

        def resolve!
          game.choices.add(SurveilChoice.new(actor: card, amount: 2))
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    end
  end
end
