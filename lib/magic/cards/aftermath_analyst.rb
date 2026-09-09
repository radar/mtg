module Magic
  module Cards
    AftermathAnalyst = Creature("Aftermath Analyst") do
      cost generic: 1, green: 1
      creature_type "Elf Detective"
      power 2
      toughness 2
    end

    class AftermathAnalyst < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.mill(3)
        end
      end

      class ReturnLandsAbility < Magic::ActivatedAbility
        costs "{3}{G}, Sacrifice {this}"

        def resolve!
          controller.graveyard.lands.each { |land| land.resolve!(enters_tapped: true) }
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [ReturnLandsAbility]
    end
  end
end
