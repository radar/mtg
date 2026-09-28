module Magic
  module Cards
    MoongloveExtractor = Creature("Moonglove Extractor") do
      cost generic: 2, black: 1
      creature_type("Elf Warlock")
      power 2
      toughness 1
    end

    class MoongloveExtractor < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          trigger_effect(:draw_card)
          trigger_effect(:lose_life, target: controller, life: 1)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
