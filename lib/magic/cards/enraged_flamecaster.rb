module Magic
  module Cards
    class EnragedFlamecaster < Creature
      card_name "Enraged Flamecaster"
      cost generic: 2, red: 1
      creature_type "Elemental Sorcerer"
      power 3
      toughness 2
      keywords :reach

      # "Whenever you cast a spell with mana value 4 or greater, this creature deals 2 damage to each
      # opponent."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.mana_value >= 4

        def call
          game.opponents(controller).each { trigger_effect(:deal_damage, target: _1, damage: 2) }
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
