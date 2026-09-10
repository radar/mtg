module Magic
  module Cards
    BeastWhisperer = Creature("Beast Whisperer") do
      cost generic: 2, green: 2
      creature_type "Elf Druid"
      power 2
      toughness 3
    end

    class BeastWhisperer < Creature
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          spell.creature? && you?
        end

        def call
          actor.trigger_effect(:draw_cards)
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end
