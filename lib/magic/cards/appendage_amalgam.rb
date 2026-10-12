module Magic
  module Cards
    AppendageAmalgam = Creature("Appendage Amalgam") do
      cost generic: 2, black: 1
      enchantment_creature_type("Horror")
      keywords :flash
      power 3
      toughness 2
    end

    class AppendageAmalgam < Creature
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
