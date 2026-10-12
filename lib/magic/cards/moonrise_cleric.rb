module Magic
  module Cards
    MoonriseCleric = Creature("Moonrise Cleric") do
      cost generic: 1, black_or_white: 2
      creature_type("Bat Cleric")
      keywords :flying
      power 2
      toughness 3
    end

    class MoonriseCleric < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
