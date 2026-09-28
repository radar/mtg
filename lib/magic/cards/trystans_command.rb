module Magic
  module Cards
    TrystansCommand = Sorcery("Trystan's Command") do
      cost generic: 4, black: 1, green: 1
      type T::Kindred, T::Sorcery, T::Creatures["Elf"]
    end

    class TrystansCommand < Sorcery
      class CopyElf < CopyTokenMode
        creature_type "Elf"
      end

      class Return < Mode
        def target_choices = controller.graveyard.cards.select(&:permanent?)

        def resolve!(targets:)
          targets.first(2).each { _1.move_to_hand!(controller) }
        end
      end

      class Destroy < Mode
        def target_choices = battlefield.creatures + battlefield.permanents.enchantments

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class PumpAndUntap < Mode
        def target_choices = game.players

        def resolve!(target:)
          target.creatures.each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: 3, toughness: 3)
            creature.untap!
          end
        end
      end

      modes CopyElf, Return, Destroy, PumpAndUntap
    end
  end
end
