module Magic
  module Cards
    InspiritedVanguard = Creature("Inspirited Vanguard") do
      cost generic: 4, green: 1
      creature_type("Human Soldier")
      power 3
      toughness 2
    end

    class InspiritedVanguard < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: 2))
        end
      end

      def etb_triggers = [EntersTrigger]

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: 2))
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
