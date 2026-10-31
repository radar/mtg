module Magic
  module Cards
    EreborFlamesmith = Creature("Erebor Flamesmith") do
      cost generic: 1, red: 1
      creature_type "Dwarf Artificer"
      power 2
      toughness 1
    end

    class EreborFlamesmith < Creature
      # "Whenever you cast an instant or sorcery spell, this creature deals 1 damage to each opponent."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && (spell.instant? || spell.sorcery?)

        def call
          opponents.each { |opponent| actor.deal_damage(1, to: opponent) }
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
