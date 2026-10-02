module Magic
  module Cards
    SkeletonArcher = Creature("Skeleton Archer") do
      cost generic: 3, black: 1
      creature_type("Skeleton Archer")
      power 3
      toughness 3
    end

    class SkeletonArcher < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.any_target
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:deal_damage, target: target, damage: 1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
