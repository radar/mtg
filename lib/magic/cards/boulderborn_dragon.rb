module Magic
  module Cards
    BoulderbornDragon = Creature("Boulderborn Dragon") do
      cost generic: 5
      artifact_creature_type("Dragon")
      keywords :flying, :vigilance
      power 3
      toughness 3
    end

    class BoulderbornDragon < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
