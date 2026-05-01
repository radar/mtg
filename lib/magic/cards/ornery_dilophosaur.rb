module Magic
  module Cards
    OrneryDilophosaur = Creature("Ornery Dilophosaur") do
      creature_type "Dinosaur"
      cost generic: 2, green: 1
      power 3
      toughness 3
      keywords :deathtouch
    end

    class OrneryDilophosaur < Creature
      class AttackTrigger < TriggeredAbility
        def should_perform?
          return false unless event.attacks.any? { |attack| attack.attacker == actor }

          creatures_you_control.with_power { |power| power >= 4 }.any?
        end

        def call
          actor.trigger_effect(:modify_power_toughness, power: 2, toughness: 2, target: actor, until_eot: true)
        end
      end

      def event_handlers
        {
          Events::FinalAttackersDeclared => AttackTrigger
        }
      end
    end
  end
end
