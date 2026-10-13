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
          draw_cards(2, player: target)
        end
      end

      class Damage < Mode
        def target_choices = game.players

        def resolve!(target:)
          target.creatures.to_a.each { deal_damage(2, to: _1) }
        end
      end

      class Treasures < Mode
        def target_choices = game.players

        def resolve!(target:)
          create_token(token:Tokens::Treasure, controller: target, amount: 2)
        end
      end

      modes CopyElemental, Draw, Damage, Treasures
      choose_modes 2
    end
  end
end
