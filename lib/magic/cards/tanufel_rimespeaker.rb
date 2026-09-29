module Magic
  module Cards
    class TanufelRimespeaker < Creature
      card_name "Tanufel Rimespeaker"
      cost generic: 3, blue: 1
      creature_type "Elemental Wizard"
      power 2
      toughness 4

      # "Whenever you cast a spell with mana value 4 or greater, draw a card."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.mana_value >= 4

        def call
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
