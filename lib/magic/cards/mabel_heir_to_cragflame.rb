module Magic
  module Cards
    MabelHeirToCragflame = Creature("Mabel, Heir to Cragflame") do
      legendary_creature_type "Mouse Soldier"
      cost generic: 1, red: 1, white: 1
      power 3
      toughness 3
    end

    class MabelHeirToCragflame < Creature
      # Other Mice you control get +1/+1.
      class MiceBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        def applicable_targets = (source.controller.creatures - [source]).select { _1.type?("Mouse") }
      end

      def static_abilities = [MiceBuff]

      # When Mabel enters, create Cragflame, a legendary colorless Equipment artifact token with "Equipped
      # creature gets +1/+1 and has vigilance, trample, and haste" and equip {2}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token:Tokens::Cragflame)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
