module Magic
  module Cards
    AvengerOfTheFallen = Creature("Avenger of the Fallen") do
      cost generic: 2, black: 1
      creature_type("Human Warrior")
      keywords :deathtouch
      power 2
      toughness 4
    end

    class AvengerOfTheFallen < Creature
      class MobilizeTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        WarriorToken = Token.create "Warrior" do
          creature_type "Warrior"
          power 1
          toughness 1
          colors :red
        end

        class SacrificeTokenTrigger < TriggeredAbility::BeginningOfEndStep
          def call = actor.sacrifice!
        end

        def call
          Array(trigger_effect(:create_token, token_class: WarriorToken, amount: controller.graveyard.creatures.count, enters_tapped: true, attacking: true, attack_target: game.current_turn.attacks.find { _1.attacker == actor }&.target)).each do |token|
            token.register_turn_trigger(Events::BeginningOfEndStep, SacrificeTokenTrigger)
          end
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => MobilizeTrigger }
    end
  end
end
