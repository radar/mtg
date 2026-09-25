module Magic
  module Cards
    EclipsedMerrow = Creature("Eclipsed Merrow") do
      cost blue_or_white: 3
      creature_type("Merfolk Scout")
      power 2
      toughness 3
    end

    class EclipsedMerrow < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 4, filter: ->(card) { card.any_type?("Merfolk", "Plains", "Island") }))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
