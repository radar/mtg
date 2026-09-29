module Magic
  module Cards
    class KulrathMystic < Creature
      card_name "Kulrath Mystic"
      cost generic: 2, blue: 1
      creature_type "Elemental Wizard"
      power 2
      toughness 4

      # "Whenever you cast a spell with mana value 4 or greater, this creature gets +2/+0 and gains
      # vigilance until end of turn."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.mana_value >= 4

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 2, toughness: 0)
          trigger_effect(:grant_keyword, target: actor, keyword: :vigilance)
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
