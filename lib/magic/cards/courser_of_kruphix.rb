module Magic
  module Cards
    CourserOfKruphix = Creature("Courser of Kruphix") do
      enchantment_creature_type "Centaur"
      cost generic: 1, green: 2
      power 2
      toughness 4
    end

    class CourserOfKruphix < Creature
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          event.player == controller
        end

        def call
          controller.gain_life(1)
        end
      end

      def etb_triggers
        [RevealTopCard]
      end

      class RevealTopCard < TriggeredAbility::EnterTheBattlefield
        def call
          controller.library.first&.reveal!
        end
      end

      def event_handlers
        { Events::Landfall => LandfallTrigger }
      end
    end
  end
end