module Magic
  module Cards
    FearOfSurveillance = Creature("Fear of Surveillance") do
      cost generic: 1, white: 1
      enchantment_creature_type("Nightmare")
      keywords :vigilance
      power 2
      toughness 2
    end

    class FearOfSurveillance < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
