module Magic
  module Cards
    LasydProwler = Creature("Lasyd Prowler") do
      cost generic: 2, green: 2
      creature_type("Snake Ranger")
      power 5
      toughness 5
    end

    class LasydProwler < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{1}{G}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: controller.graveyard.lands.count)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          def resolve!
            controller.mill(controller.lands.count)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
