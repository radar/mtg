module Magic
  module Cards
    ElvishRegrower = Creature("Elvish Regrower") do
      cost generic: 2, green: 2
      creature_type("Elf Druid")
      power 4
      toughness 3
    end

    class ElvishRegrower < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select(&:permanent?)
          end

          def choice_amount = 1

          def resolve!(target:)
            target.move_to_hand!
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
