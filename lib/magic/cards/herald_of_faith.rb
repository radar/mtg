module Magic
  module Cards
    HeraldOfFaith = Creature("Herald of Faith") do
      cost generic: 3, white: 2
      creature_type("Angel")
      keywords :flying
      power 4
      toughness 3
    end

    class HeraldOfFaith < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
