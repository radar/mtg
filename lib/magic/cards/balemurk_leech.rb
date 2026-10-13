module Magic
  module Cards
    BalemurkLeech = Creature("Balemurk Leech") do
      cost generic: 1, black: 1
      creature_type "Leech"
      power 2
      toughness 2
    end

    class BalemurkLeech < Creature
      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, each opponent loses
      # 1 life."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          opponents.each { lose_life(_1, 1) }
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
