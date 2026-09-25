module Magic
  module Cards
    EclipsedBoggart = Creature("Eclipsed Boggart") do
      cost black_or_red: 3
      creature_type("Goblin Scout")
      power 2
      toughness 3
    end

    class EclipsedBoggart < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 4, filter: ->(card) { card.any_type?("Goblin", "Swamp", "Mountain") }))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
