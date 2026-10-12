module Magic
  module Cards
    ErraticApparition = Creature("Erratic Apparition") do
      cost generic: 2, blue: 1
      creature_type "Spirit"
      keywords :flying, :vigilance
      power 1
      toughness 3
    end

    class ErraticApparition < Creature
      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, this creature gets
      # +1/+1 until end of turn."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          pump(actor, 1, 1)
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
