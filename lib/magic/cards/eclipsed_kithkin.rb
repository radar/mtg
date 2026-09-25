module Magic
  module Cards
    EclipsedKithkin = Creature("Eclipsed Kithkin") do
      cost green_or_white: 2
      creature_type("Kithkin Scout")
      power 2
      toughness 1
    end

    class EclipsedKithkin < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 4, filter: ->(card) { card.any_type?("Kithkin", "Forest", "Plains") }))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
