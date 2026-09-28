module Magic
  module Cards
    GrubsCommand = Sorcery("Grub's Command") do
      cost generic: 3, black: 1, red: 1
      type T::Kindred, T::Sorcery, T::Creatures["Goblin"]
    end

    class GrubsCommand < Sorcery
      class CopyGoblin < CopyTokenMode
        creature_type "Goblin"
      end

      class Buff < Mode
        def target_choices = game.players

        def resolve!(target:)
          target.creatures.each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: 1, toughness: 1)
            creature.grant_haste!
          end
        end
      end

      class Destroy < Mode
        def target_choices = battlefield.creatures + battlefield.permanents.by_any_type(T::Artifact)

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class Mill < Mode
        def target_choices = game.players

        def resolve!(target:)
          target.mill(5).select { _1.type?("Goblin") }.each { _1.move_to_hand!(target) }
        end
      end

      modes CopyGoblin, Buff, Destroy, Mill
      choose_modes 2
    end
  end
end
