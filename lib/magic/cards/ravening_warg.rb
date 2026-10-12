module Magic
  module Cards
    RaveningWarg = Creature("Ravening Warg") do
      cost generic: 1, black: 1
      creature_type("Wolf")
      keywords :deathtouch
      power 2
      toughness 2
    end

    class RaveningWarg < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && (controller.creatures.any? { _1.power >= 4 })
        end

        def call
          gain_life(2)
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
