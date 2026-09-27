module Magic
  module Cards
    FlockImpostor = Creature("Flock Impostor") do
      cost generic: 2, white: 1
      creature_type("Shapeshifter")
      keywords :changeling, :flash, :flying
      power 2
      toughness 2
    end

    class FlockImpostor < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.controlled_by(controller).creatures - [actor])
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
