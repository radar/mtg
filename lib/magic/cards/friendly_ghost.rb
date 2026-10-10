module Magic
  module Cards
    FriendlyGhost = Creature("Friendly Ghost") do
      cost generic: 3, white: 1
      creature_type("Spirit")
      keywords :flying
      power 2
      toughness 4
    end

    class FriendlyGhost < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: 2, toughness: 4)
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
