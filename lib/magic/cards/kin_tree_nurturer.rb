module Magic
  module Cards
    KinTreeNurturer = Creature("Kin-Tree Nurturer") do
      cost generic: 2, black: 1
      creature_type("Human Druid")
      keywords :lifelink
      power 2
      toughness 1
    end

    class KinTreeNurturer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: 1))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
