module Magic
  module Cards
    DevotedDuelist = Creature("Devoted Duelist") do
      cost generic: 1, red: 1
      creature_type("Goblin Monk")
      keywords :haste
      power 2
      toughness 1
    end

    class DevotedDuelist < Creature
      class FlurryTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && second_spell_this_turn?
        end

        def call
          game.opponents(controller).each { trigger_effect(:deal_damage, target: _1, damage: 1) }
        end
      end

      def event_handlers = { Events::SpellCast => FlurryTrigger }
    end
  end
end
