module Magic
  module Cards
    ScurrilousSentry = Creature("Scurrilous Sentry") do
      cost generic: 3, black: 1
      creature_type "Human Knight Rogue"
      power 2
      toughness 3
      keywords :menace
    end

    class ScurrilousSentry < Creature
      # "Whenever this creature enters or attacks, it connives."
      class ConniveTrigger < TriggeredAbility
        def call
          connive
        end
      end

      class EntersTrigger < ConniveTrigger
      end

      class AttacksTrigger < ConniveTrigger
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, a, b| Array(a) + Array(b) }
      end
    end
  end
end
