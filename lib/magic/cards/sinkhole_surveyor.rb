module Magic
  module Cards
    SinkholeSurveyor = Creature("Sinkhole Surveyor") do
      cost generic: 1, black: 1
      creature_type("Bird Scout")
      keywords :flying
      power 1
      toughness 3
    end

    class SinkholeSurveyor < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          trigger_effect(:lose_life, target: controller, life: 1)
          game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
