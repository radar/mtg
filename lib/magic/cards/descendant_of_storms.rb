module Magic
  module Cards
    DescendantOfStorms = Creature("Descendant of Storms") do
      cost white: 1
      creature_type("Human Soldier")
      power 2
      toughness 1
    end

    class DescendantOfStorms < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class PayManaChoice < Magic::Choice::PayMana
          def resolve!(**args)
            super(**args)
            game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: 1))
          end
        end

        def call
          game.choices.add(PayManaChoice.new(actor: actor, mana: {:generic=>1, :white=>1})) if Magic::Choice::PayMana.new(actor: actor, mana: {:generic=>1, :white=>1}).can_pay?
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
