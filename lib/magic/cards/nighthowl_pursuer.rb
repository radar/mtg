module Magic
  module Cards
    NighthowlPursuer = Creature("Nighthowl Pursuer") do
      cost black: 1
      creature_type("Wolf")
      keywords :menace
      power 1
      toughness 1
    end

    class NighthowlPursuer < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && (controller.creatures.any? { _1.power >= 4 })
        end

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 2, toughness: 2)
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
