module Magic
  module Cards
    BillowingShriekmass = Creature("Billowing Shriekmass") do
      cost generic: 3, black: 1
      creature_type("Spirit")
      keywords :flying
      power 2
      toughness 3
    end

    class BillowingShriekmass < Creature
      class SelfBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 1
        applicable_targets { [source] }
        conditions { controller.graveyard.cards.count >= 7 }
      end

      def static_abilities = [SelfBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.mill(3)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
