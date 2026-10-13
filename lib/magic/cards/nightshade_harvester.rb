module Magic
  module Cards
    NightshadeHarvester = Creature("Nightshade Harvester") do
      cost generic: 3, black: 1
      creature_type "Elf Shaman"
      power 2
      toughness 2
    end

    class NightshadeHarvester < Creature
      # "Whenever a land an opponent controls enters, that player loses 1 life. Put a +1/+1 counter on this creature."
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = opponents.include?(event.player)

        def call
          lose_life event.player, 1
          add_counter "+1/+1"
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
