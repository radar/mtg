module Magic
  module Cards
    SunshowerDruid = Creature("Sunshower Druid") do
      cost green: 1
      creature_type("Frog Druid")
      power 0
      toughness 2
    end

    class SunshowerDruid < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            add_counter("+1/+1", to: target)
            gain_life(1)
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
