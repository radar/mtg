module Magic
  module Cards
    CantankerousKeepers = Creature("Cantankerous Keepers") do
      cost generic: 5, green: 1
      creature_type("Elf Soldier")
      power 4
      toughness 3
    end

    class CantankerousKeepers < Creature
      affinity("Elf")

      # "When this creature enters, mill four cards, then put all Elf cards from among them into your hand."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.mill(4).select { _1.type?("Elf") }.each(&:move_to_hand!)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
