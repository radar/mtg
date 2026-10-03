module Magic
  module Cards
    CephalidInkmage = Creature("Cephalid Inkmage") do
      cost generic: 2, blue: 1
      creature_type("Octopus Wizard")
      power 2
      toughness 2
    end

    class CephalidInkmage < Creature
      def can_be_blocked?(_) = !(controller.graveyard.cards.count >= 7)

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 3))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
