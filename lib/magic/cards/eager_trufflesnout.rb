module Magic
  module Cards
    EagerTrufflesnout = Creature("Eager Trufflesnout") do
      cost generic: 2, green: 1
      creature_type("Boar")
      keywords :trample
      power 4
      toughness 2
    end

    class EagerTrufflesnout < Creature
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.is_a?(Magic::Player)
        end

        def call
          trigger_effect(:create_token, token_class: Tokens::Food)
        end
      end

      def event_handlers = { Events::CombatDamageDealt => CombatDamageTrigger }
    end
  end
end
