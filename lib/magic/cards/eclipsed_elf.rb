module Magic
  module Cards
    EclipsedElf = Creature("Eclipsed Elf") do
      cost black_or_green: 3
      creature_type("Elf Scout")
      power 3
      toughness 2
    end

    class EclipsedElf < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 4, filter: ->(card) { card.any_type?("Elf", "Swamp", "Forest") }))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
