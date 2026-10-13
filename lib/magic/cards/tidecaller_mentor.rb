module Magic
  module Cards
    TidecallerMentor = Creature("Tidecaller Mentor") do
      cost generic: 1, blue: 1, black: 1
      creature_type("Rat Wizard")
      keywords :menace
      power 3
      toughness 3
    end

    class TidecallerMentor < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          super && (controller.graveyard.cards.count >= 7)
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.nonland
          end

          def choice_amount = 0..1

          def resolve!(target:)
            bounce(target)
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
