module Magic
  module Cards
    TheMountainKingsReturn = Saga("The Mountain-king's Return") do
      cost generic: 2, white: 1
    end

    class TheMountainKingsReturn < Saga
      # I -- Recruit.
      class Chapter1 < Saga::ChapterAbility
        def resolve!
          Magic::Recruit.call(player: controller)
        end
      end

      # II -- Return target creature card with mana value 3 or less from your graveyard to the battlefield.
      class Chapter2 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.cards.select { _1.creature? && _1.mana_value <= 3 }

          def choice_amount = 1

          def resolve!(target:)
            target.resolve!
          end
        end

        def resolve!
          game.add_choice(TargetChoice.new(actor: actor)) if TargetChoice.new(actor: actor).choices.any?
        end
      end

      # III -- Put a +1/+1 counter on up to one target creature.
      class Chapter3 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = game.battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target: nil)
            return unless target

            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          end
        end

        def resolve!
          game.add_choice(TargetChoice.new(actor: actor))
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3]
    end
  end
end
