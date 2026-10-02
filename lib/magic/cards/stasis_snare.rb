module Magic
  module Cards
    StasisSnare = Enchantment("Stasis Snare") do
      cost generic: 1, white: 2
      keywords :flash
    end

    class StasisSnare < Enchantment
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            actor.exile_until_leaves!(target)
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
