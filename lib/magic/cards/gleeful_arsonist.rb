module Magic
  module Cards
    GleefulArsonist = Creature("Gleeful Arsonist") do
      cost generic: 2, red: 1
      creature_type "Human Wizard"
      power 1
      toughness 2
    end

    class GleefulArsonist < Creature
      # "Whenever an opponent casts a noncreature spell, this creature deals damage equal to its power to that player."
      class NoncreatureSpellTrigger < TriggeredAbility::SpellCast
        def should_perform?
          opponents.include?(event.player) && !event.spell.creature?
        end

        def call
          actor.trigger_effect(:deal_damage, source: actor, target: event.player, damage: actor.power)
        end
      end

      def event_handlers = { Events::SpellCast => NoncreatureSpellTrigger }

      # Undying
      def death_triggers = [DeathReturn::Undying]
    end
  end
end
