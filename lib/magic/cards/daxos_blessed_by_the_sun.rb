module Magic
  module Cards
    class DaxosBlessedByTheSun < Creature
      card_name "Daxos, Blessed By The Sun"
      type T::Legendary, T::Enchantment, T::Creature, T::Creatures["Demigod"]

      cost white: 2
      power 2

      def base_toughness
        controller.devotion(:white)
      end

      class LifeGain < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature?
        end

        def call
          actor.trigger_effect(:gain_life)
        end
      end

      def event_handlers
        {
          # Whenever another creature you control enters or dies...
          Events::EnteredTheBattlefield => LifeGain,
          Events::CreatureDied => LifeGain
        }
      end
    end
  end
end
