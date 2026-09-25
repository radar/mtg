module Magic
  module Cards
    ScarbladeScout = Creature("Scarblade Scout") do
      cost generic: 1, black: 1
      creature_type("Elf Scout")
      keywords :lifelink
      power 2
      toughness 2
    end

    class ScarbladeScout < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.mill(2)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
