module Magic
  module Cards
    class SafewrightCavalry < Creature
      card_name "Safewright Cavalry"
      cost generic: 3, green: 1
      creature_type "Elf Warrior"
      power 4
      toughness 4

      # "This creature can't be blocked by more than one creature."
      def maximum_blockers = 1

      # "{5}: Target Elf you control gets +2/+2 until end of turn."
      class PumpAbility < Magic::ActivatedAbility
        costs "{5}"

        def target_choices = controller.creatures.by_type("Elf")

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target:, power: 2, toughness: 2)
        end
      end

      def activated_abilities = [PumpAbility]
    end
  end
end
