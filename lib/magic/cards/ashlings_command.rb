module Magic
  module Cards
    AshlingsCommand = Instant("Ashling's Command") do
      cost generic: 3, blue: 1, red: 1
      type T::Kindred, T::Instant, T::Creatures["Elemental"]
    end

    class AshlingsCommand < Instant
      class CopyElemental < CopyTokenMode
        creature_type "Elemental"
      end

      class Draw < Mode
        def target_choices = game.players

        def resolve!(target:)
          trigger_effect(:draw_cards, player: target, number_to_draw: 2)
        end
      end

      class Damage < Mode
        def target_choices = game.players

        def resolve!(target:)
          target.creatures.to_a.each { trigger_effect(:deal_damage, target: _1, damage: 2) }
        end
      end

      class Treasures < Mode
        def target_choices = game.players

        def resolve!(target:)
          trigger_effect(:create_token, token_class: Tokens::Treasure, controller: target, amount: 2)
        end
      end

      modes CopyElemental, Draw, Damage, Treasures
      choose_modes 2
    end
  end
end
