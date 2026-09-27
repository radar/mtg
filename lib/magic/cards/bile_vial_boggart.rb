module Magic
  module Cards
    BileVialBoggart = Creature("Bile-Vial Boggart") do
      cost black: 1
      creature_type("Goblin Assassin")
      power 1
      toughness 1
    end

    class BileVialBoggart < Creature
      class DiesTrigger < TriggeredAbility::Death
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.creatures
          end

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "-1/-1", target: target, amount: 1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
