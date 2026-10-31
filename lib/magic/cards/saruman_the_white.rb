module Magic
  module Cards
    SarumanTheWhite = Creature("Saruman the White") do
      cost generic: 4, blue: 1
      legendary_creature_type "Avatar Wizard"
      ward generic: 2
      power 4
      toughness 4
    end

    class SarumanTheWhite < Creature
      # Whenever you cast your second spell each turn, amass Orcs 2.
      class SecondSpellTrigger < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && second_spell_this_turn?

        def call
          Magic::Amass.call(source: self, controller: controller, amount: 2, subtype: "Orc")
        end
      end

      def event_handlers
        handlers = super
        handlers.merge(Events::SpellCast => [*handlers[Events::SpellCast], SecondSpellTrigger])
      end
    end
  end
end
