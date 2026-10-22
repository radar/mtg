module Magic
  module Cards
    RoilCartographer = Creature("Roil Cartographer") do
      cost generic: 1, blue: 1
      creature_type "Merfolk Rogue"
      power 1
      toughness 3
    end

    class RoilCartographer < Creature
      # Landfall -- Whenever a land you control enters, you get {E}.
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          event.player == controller
        end

        def call
          gain_energy 1
        end
      end

      # {T}, Pay six {E}: Draw three cards.
      class DrawAbility < ActivatedAbility
        costs "{T}, Pay {E}{E}{E}{E}{E}{E}"

        def resolve!
          draw_cards 3
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }

      def activated_abilities = [DrawAbility]
    end
  end
end
