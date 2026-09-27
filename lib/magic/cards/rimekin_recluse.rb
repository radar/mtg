module Magic
  module Cards
    RimekinRecluse = Creature("Rimekin Recluse") do
      cost generic: 2, blue: 1
      creature_type("Elemental Wizard")
      power 3
      toughness 2
    end

    class RimekinRecluse < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.creatures - [actor])
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
