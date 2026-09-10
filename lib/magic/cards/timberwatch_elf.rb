module Magic
  module Cards
    TimberwatchElf = Creature("Timberwatch Elf") do
      creature_type "Elf"
      cost generic: 2, green: 1
      power 1
      toughness 2
    end

    class TimberwatchElf < Creature
      class PumpAbility < Magic::ActivatedAbility
        costs "{T}"

        def single_target?
          true
        end

        def target_choices
          game.battlefield.creatures
        end

        def resolve!(target:)
          x = game.battlefield.creatures.by_any_type("Elf").count
          trigger_effect(:modify_power_toughness, power: x, toughness: x, target: target, until_eot: true)
        end
      end

      def activated_abilities = [PumpAbility]
    end
  end
end
