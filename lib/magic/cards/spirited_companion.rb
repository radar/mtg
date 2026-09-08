module Magic
  module Cards
    SpiritedCompanion = Creature("Spirited Companion") do
      type T::Enchantment, T::Creature, T::Creatures["Dog"]
      cost generic: 1, white: 1
      power 1
      toughness 1
    end

    class SpiritedCompanion < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.draw!
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end