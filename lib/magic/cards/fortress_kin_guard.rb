module Magic
  module Cards
    FortressKinGuard = Creature("Fortress Kin-Guard") do
      cost generic: 1, white: 1
      creature_type("Dog Soldier")
      power 1
      toughness 2
    end

    class FortressKinGuard < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: 1))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
