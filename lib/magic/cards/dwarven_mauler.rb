module Magic
  module Cards
    DwarvenMauler = Creature("Dwarven Mauler") do
      cost red: 1
      creature_type("Dwarf Warrior")
      power 2
      toughness 1
    end

    class DwarvenMauler < Creature
      # "Equip abilities you activate that target this creature cost {2} less to activate."
      class EquipDiscount < StaticAbility
        def activation_cost_reduction_for_targets(ability, targets, player)
          return 0 unless player == controller && ability.respond_to?(:equip?) && ability.equip?

          targets.include?(@source) ? 2 : 0
        end
      end

      def static_abilities = [EquipDiscount]
    end
  end
end
