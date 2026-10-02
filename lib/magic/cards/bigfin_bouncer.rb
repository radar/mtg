module Magic
  module Cards
    BigfinBouncer = Creature("Bigfin Bouncer") do
      cost generic: 3, blue: 1
      creature_type("Shark Pirate")
      power 3
      toughness 2
    end

    class BigfinBouncer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).creatures
          end

          def choice_amount = 1

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
