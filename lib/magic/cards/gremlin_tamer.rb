module Magic
  module Cards
    GremlinTamer = Creature("Gremlin Tamer") do
      cost white: 1, blue: 1
      creature_type "Human Scout"
      power 2
      toughness 2
    end

    class GremlinTamer < Creature
      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, create a 1/1 red
      # Gremlin creature token."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          create_token(token:MidnightMayhem::GremlinToken)
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
