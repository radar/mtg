module Magic
  module Cards
    TrappedInTheScreen = Enchantment("Trapped in the Screen") do
      cost generic: 2, white: 1
      ward generic: 2
    end

    class TrappedInTheScreen < Enchantment
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).select { |p| p.artifact? || p.creature? || p.enchantment? }
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
