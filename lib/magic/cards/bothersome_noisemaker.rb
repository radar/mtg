module Magic
  module Cards
    BothersomeNoisemaker = Creature("Bothersome Noisemaker") do
      cost generic: 1, red: 1
      creature_type("Goblin Bard")
      power 2
      toughness 2
    end

    class BothersomeNoisemaker < Creature
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !spell.type?("Creature")
        end

        def call
          Amass.call(source: actor, controller: controller, amount: 1)
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
