module Magic
  module Cards
    HaraldKingOfSkemfar = Creature("Harald, King of Skemfar") do
      cost generic: 1, black: 1, green: 1
      legendary_creature_type "Elf Warrior"
      keywords :menace
      power 3
      toughness 2
    end

    class HaraldKingOfSkemfar < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 5, filter: ->(card) { card.any_type?("Elf", "Warrior", "Tyvar") }))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
