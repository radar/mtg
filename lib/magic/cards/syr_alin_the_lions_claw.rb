module Magic
  module Cards
    SyrAlinTheLionsClaw = Creature("Syr Alin, the Lion's Claw") do
      cost generic: 3, white: 2
      legendary_creature_type("Human Knight")
      keywords :first_strike
      power 4
      toughness 4
    end

    class SyrAlinTheLionsClaw < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          (battlefield.controlled_by(controller).creatures - [actor]).each { |creature| trigger_effect(:modify_power_toughness, target: creature, power: 1, toughness: 1) }
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
