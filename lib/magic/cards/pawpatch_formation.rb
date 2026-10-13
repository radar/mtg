module Magic
  module Cards
    PawpatchFormation = Instant("Pawpatch Formation") do
      cost generic: 1, green: 1
    end

    class PawpatchFormation < Instant
      class Mode1 < Mode
        def target_choices
          battlefield.creatures.select { _1.has_keyword?(Keywords::FLYING) }
        end

        def resolve!(target:)
          destroy(target)
        end
      end

      class Mode2 < Mode
        def target_choices
          battlefield.enchantments
        end

        def resolve!(target:)
          destroy(target)
        end
      end

      class Mode3 < Mode
        def resolve!
          trigger_effect(:draw_card)
          trigger_effect(:create_token, token_class: Tokens::Food)
        end
      end

      modes Mode1, Mode2, Mode3
      choose_modes 1
    end
  end
end
