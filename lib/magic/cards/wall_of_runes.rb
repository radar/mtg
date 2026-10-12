module Magic
  module Cards
    WallOfRunes = Creature("Wall of Runes") do
      cost blue: 1
      creature_type("Wall")
      keywords :defender
      power 0
      toughness 4
    end

    class WallOfRunes < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Scry.new(actor: actor, amount: 1))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
