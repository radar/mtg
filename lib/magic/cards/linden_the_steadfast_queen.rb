module Magic
  module Cards
    LindenTheSteadfastQueen = Creature("Linden, the Steadfast Queen") do
      cost white: 3
      legendary_creature_type("Human Noble")
      keywords :vigilance
      power 3
      toughness 3
    end

    class LindenTheSteadfastQueen < Creature
      class CreatureAttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacker.controller == controller && event.attacker.colors.include?(:white)
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers = { Events::CreatureAttacked => CreatureAttacksTrigger }
    end
  end
end
