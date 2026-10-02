module Magic
  module Cards
    FirespitterWhelp = Creature("Firespitter Whelp") do
      cost generic: 2, red: 1
      creature_type("Dragon")
      keywords :flying
      power 2
      toughness 2
    end

    class FirespitterWhelp < Creature
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (!spell.type?("Creature") || spell.type?("Dragon"))
        end

        def call
          game.opponents(controller).each { trigger_effect(:deal_damage, target: _1, damage: 1) }
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
