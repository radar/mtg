module Magic
  module Cards
    DuskwatchHunter = Creature("Duskwatch Hunter") do
      cost generic: 2, black_or_green: 1
      creature_type("Wolf")
      power 3
      toughness 1
    end

    class DuskwatchHunter < Creature
      def can_be_blocked?(blocker) = !blocker.token?

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
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
