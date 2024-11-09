module Magic
  module Cards
    EidolonOfBlossoms = Creature("Eidolon of Blossoms") do
      enchantment_creature_type "Spirit"
      cost generic: 2, green: 2
      power 2
      toughness 2
    end

    class EidolonOfBlossoms < Creature
      class LifeGain < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          enchantment? && under_your_control?
        end

        def call
          actor.trigger_effect(:draw)
        end
      end

      def event_handlers
        {
          #  Whenever this or another enchantment you control enters, draw a card.
          Events::EnteredTheBattlefield => LifeGain
        }
      end
    end
  end
end
