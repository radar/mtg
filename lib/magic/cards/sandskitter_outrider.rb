module Magic
  module Cards
    SandskitterOutrider = Creature("Sandskitter Outrider") do
      cost generic: 3, black: 1
      creature_type("Goblin Soldier")
      keywords :menace
      power 2
      toughness 1
    end

    class SandskitterOutrider < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: 2))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
