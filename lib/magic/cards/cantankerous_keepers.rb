module Magic
  module Cards
    CantankerousKeepers = Creature("Cantankerous Keepers") do
      cost generic: 5, green: 1
      creature_type("Elf Soldier")
      power 4
      toughness 3
    end

    class CantankerousKeepers < Creature
      # "Affinity for Elves (This spell costs {1} less to cast for each Elf you control.)"
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -[game.battlefield.controlled_by(player).count { _1.type?("Elf") }, 5].min } }
      end

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
