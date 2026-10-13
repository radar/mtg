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

          creatures_you_control.power_gte(4).any?
        end

        def call
          pump actor, 2, 2
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
