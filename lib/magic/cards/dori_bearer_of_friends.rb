module Magic
  module Cards
    DoriBearerOfFriends = Creature("Dori, Bearer of Friends") do
      cost generic: 2, red: 1
      legendary_creature_type("Dwarf Warrior")
      keywords :trample
      power 3
      toughness 2
    end

    class DoriBearerOfFriends < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Treasure)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
