module Magic
  module Cards
    MischievousPup = Creature("Mischievous Pup") do
      cost generic: 2, white: 1
      creature_type("Dog")
      keywords :flash
      power 3
      toughness 1
    end

    class MischievousPup < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.controlled_by(controller).permanents - [actor])
          end

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:return_to_owners_hand, target: target)
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
