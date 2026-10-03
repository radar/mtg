module Magic
  module Cards
    PiratesCutlass = Equipment("Pirate's Cutlass") do
      cost generic: 3
      equip [Costs::Mana.new(generic: 2)]
    end

    class PiratesCutlass < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 1
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures.by_any_type("Pirate")
          end

          def choice_amount = 1

          def resolve!(target:)
            actor.attach_to!(target)
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
