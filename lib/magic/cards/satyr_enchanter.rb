module Magic
  module Cards
    SatyrEnchanter = Creature("Satyr Enchanter") do
      cost generic: 1, green: 1, white: 1
      power 2
      toughness 2
      creature_type "Satyr Druid"

      class SpellCastTrigger < TriggeredAbility
        def should_perform?
          you? && event.type?("Enchantment")
        end

        def call
          actor.trigger_effect(:draw_cards, source: actor)
        end
      end

      def event_handlers
        {
          Events::SpellCast => SpellCastTrigger
        }
      end
    end
  end
end
