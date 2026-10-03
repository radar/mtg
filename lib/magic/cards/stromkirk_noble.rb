module Magic
  module Cards
    StromkirkNoble = Creature("Stromkirk Noble") do
      cost red: 1
      creature_type("Vampire Noble")
      power 1
      toughness 1
    end

    class StromkirkNoble < Creature
      def can_be_blocked?(blocker) = !blocker.type?("Human")

      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.is_a?(Magic::Player)
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      def event_handlers = { Events::CombatDamageDealt => CombatDamageTrigger }
    end
  end
end
