module Magic
  module Cards
    SanguineSyphoner = Creature("Sanguine Syphoner") do
      cost generic: 1, black: 1
      creature_type("Vampire Warlock")
      power 1
      toughness 3
    end

    class SanguineSyphoner < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: 1) }
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
