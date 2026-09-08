module Magic
  module Cards
    SythisHarvestsHand = Creature("Sythis, Harvest's Hand") do
      type T::Super::Legendary, T::Enchantment, T::Creature, T::Creatures["Nymph"]
      cost green: 1, white: 1
      power 1
      toughness 2
    end

    class SythisHarvestsHand < Creature
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && enchantment?
        end

        def call
          controller.gain_life(1)
          controller.draw!
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end