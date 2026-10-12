module Magic
  module Cards
    WellWornSpatula = Equipment("Well-Worn Spatula") do
      cost generic: 1
      equip [Costs::Mana.new(generic: 1)]
    end

    class WellWornSpatula < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
