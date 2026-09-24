module Magic
  module Cards
    OldGnawbone = Creature("Old Gnawbone") do
      legendary_creature_type "Dragon"
      cost "{5}{G}{G}"
      power 7
      toughness 7
      keywords :flying
    end

    class OldGnawbone < Creature
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.target.player? && event.source.controller == controller
        end

        def call
          actor.trigger_effect(:create_token, token_class: Tokens::Treasure, amount: event.damage)
        end
      end

      def event_handlers
        { Events::CombatDamageDealt => CombatDamageTrigger }
      end
    end
  end
end
