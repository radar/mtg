module Magic
  module Cards
    LittleBear = Creature("Little Bear") do
      cost generic: 2, green: 1
      creature_type("Bear")
      keywords :flash
      power 3
      toughness 2
    end

    class LittleBear < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.controlled_by(controller).creatures - [actor])
          end

          def choice_amount = 1

          def resolve!(target:)
            target.untap!
            if target.type?("Bear")
              trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
            end
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
