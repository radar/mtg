module Magic
  module Cards
    BoggartPrankster = Creature("Boggart Prankster") do
      cost generic: 1, black: 1
      creature_type("Goblin Warrior")
      power 1
      toughness 3
    end

    class BoggartPrankster < Creature
      class YouAttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures.by_any_type("Goblin").attacking
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: 1, toughness: 0)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => YouAttackTrigger }
    end
  end
end
