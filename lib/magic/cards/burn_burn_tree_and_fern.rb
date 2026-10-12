module Magic
  module Cards
    BurnBurnTreeAndFern = Saga("Burn, Burn, Tree and Fern") do
      cost generic: 3, red: 1
    end

    class BurnBurnTreeAndFern < Saga
      # I -- This Saga deals 6 damage to target creature an opponent controls.
      class Chapter1 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def prompt = "Deal 6 damage to target creature an opponent controls."

          def choices
            battlefield.not_controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:deal_damage, target: target, damage: 6)
          end
        end

        def resolve!
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # II -- Destroy target artifact an opponent controls.
      class Chapter2 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def prompt = "Destroy target artifact an opponent controls."

          def choices
            battlefield.not_controlled_by(controller).by_any_type(T::Artifact)
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:destroy_target, target: target)
          end
        end

        def resolve!
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # III, IV -- Add {R}.
      class AddRed < Saga::ChapterAbility
        def resolve!
          controller.add_mana(red: 1)
        end
      end

      def chapters
        [Chapter1, Chapter2, AddRed, AddRed]
      end
    end
  end
end
