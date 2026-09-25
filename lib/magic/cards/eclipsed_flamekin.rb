module Magic
  module Cards
    EclipsedFlamekin = Creature("Eclipsed Flamekin") do
      cost generic: 1, blue_or_red: 2
      creature_type("Elemental Scout")
      power 1
      toughness 4
    end

    class EclipsedFlamekin < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 4, filter: ->(card) { card.any_type?("Elemental", "Island", "Mountain") }))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
