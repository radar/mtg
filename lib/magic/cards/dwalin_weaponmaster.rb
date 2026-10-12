module Magic
  module Cards
    DwalinWeaponmaster = Creature("Dwalin, Weaponmaster") do
      cost generic: 1, red_or_white: 1
      legendary_creature_type("Dwarf Warrior")
      keywords :first_strike
      power 2
      toughness 1
    end

    class DwalinWeaponmaster < Creature
      # "Whenever Dwalin enters or attacks, put a hone counter on each Equipment you control."
      module HoneEquipment
        def call
          battlefield.controlled_by(controller).select { _1.type?("Equipment") }.each do |equipment|
            trigger_effect(:add_counter, counter_type: "hone", target: equipment, amount: 1)
          end
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        include HoneEquipment
      end

      class AttacksTrigger < TriggeredAbility
        include HoneEquipment

        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
