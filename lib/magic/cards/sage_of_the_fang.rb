module Magic
  module Cards
    SageOfTheFang = Creature("Sage of the Fang") do
      cost generic: 2, green: 1
      creature_type("Human Druid")
      power 2
      toughness 2
    end

    class SageOfTheFang < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{3}{G}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: target.counters.of_type(Counters["+1/+1"]).count)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.creatures
          end

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
