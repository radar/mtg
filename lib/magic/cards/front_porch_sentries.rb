module Magic
  module Cards
    FrontPorchSentries = Creature("Front Porch Sentries") do
      cost generic: 1, black: 1
      creature_type("Goblin Soldier")
      power 2
      toughness 2
    end

    class FrontPorchSentries < Creature
      class DiesTrigger < TriggeredAbility::Death
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            pump(target, -1, -1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
