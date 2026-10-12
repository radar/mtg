module Magic
  module Cards
    DauntlessVeteran = Creature("Dauntless Veteran") do
      cost generic: 1, white: 2
      creature_type("Human Soldier")
      power 2
      toughness 2
    end

    class DauntlessVeteran < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          battlefield.controlled_by(controller).creatures.each { |creature| pump(creature, 1, 1) }
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
