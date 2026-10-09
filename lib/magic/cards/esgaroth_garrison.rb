module Magic
  module Cards
    EsgarothGarrison = Creature("Esgaroth Garrison") do
      cost generic: 4, white: 1
      creature_type("Human Soldier")
      power 0
      toughness 5
    end

    class EsgarothGarrison < Creature
      # "Esgaroth Garrison's power is equal to the number of creatures you control."
      class DynamicPower < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification = source.controller.creatures.count

        def toughness_modification = 0
      end

      def static_abilities = [DynamicPower]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          Magic::Recruit.call(player: controller)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
