module Magic
  module Cards
    PulseTracker = Creature("Pulse Tracker") do
      cost black: 1
      creature_type("Vampire Rogue")
      power 1
      toughness 1
    end

    class PulseTracker < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: 1) }
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
