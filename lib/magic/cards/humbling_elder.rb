module Magic
  module Cards
    HumblingElder = Creature("Humbling Elder") do
      cost blue: 1
      creature_type("Human Monk")
      keywords :flash
      power 1
      toughness 2
    end

    class HumblingElder < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: -2, toughness: 0)
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
