module Magic
  module Cards
    ChompingChangeling = Creature("Chomping Changeling") do
      cost generic: 2, green: 1
      creature_type("Shapeshifter")
      keywords :changeling
      power 1
      toughness 2
    end

    class ChompingChangeling < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.artifacts + battlefield.enchantments)
          end

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:destroy_target, target: target)
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
