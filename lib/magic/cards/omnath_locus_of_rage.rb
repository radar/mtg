module Magic
  module Cards
    OmnathLocusOfRage = Creature("Omnath, Locus of Rage") do
      legendary_creature_type "Elemental"
      cost generic: 3, red: 2, green: 2
      power 5
      toughness 5
    end

    class OmnathLocusOfRage < Creature
      ElementalToken = Token.create("Elemental") do
        creature_type "Elemental"
        power 5
        toughness 5
        colors :red, :green
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          event.player == controller
        end

        def call
          actor.create_token(token_class: ElementalToken)
        end
      end

      def event_handlers
        { Events::Landfall => LandfallTrigger }
      end
    end
  end
end