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

      # "Play with the top card of your library revealed. You may play lands from the top of your library."
      class TopOfLibrary < StaticAbility
        def permits_casting_from_top?(card)
          card == controller.library.first && card.land?
        end

        # Read by arena's Table to show the top card to both players.
        def reveals_top_card?(player)
          player == controller
        end
      end

      def static_abilities = [TopOfLibrary]

      def event_handlers
        { Events::Landfall => LandfallTrigger }
      end
    end
  end
end