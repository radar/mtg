module Magic
  module Cards
    MostValuableSlayer = Creature("Most Valuable Slayer") do
      cost generic: 3, red: 1
      creature_type("Human Warrior")
      power 2
      toughness 4
    end

    class MostValuableSlayer < Creature
      class YouAttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.creatures.attacking
          end

          def choice_amount = 1

          def resolve!(target:)
            pump(target, 1, 0)
            trigger_effect(:grant_keyword, target: target, keyword: :first_strike)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => YouAttackTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
