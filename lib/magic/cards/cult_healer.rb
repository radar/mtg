module Magic
  module Cards
    CultHealer = Creature("Cult Healer") do
      cost generic: 2, white: 1
      creature_type "Human Doctor"
      power 3
      toughness 3
    end

    class CultHealer < Creature
      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, this creature gains
      # lifelink until end of turn."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          actor.grant_keyword(Cards::Keywords::LIFELINK, until_eot: true)
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
