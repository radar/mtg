module Magic
  module Cards
    AdornedCrocodile = Creature("Adorned Crocodile") do
      cost generic: 4, black: 1
      creature_type("Crocodile")
      power 5
      toughness 3
    end

    class AdornedCrocodile < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{B}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]

      class DiesTrigger < TriggeredAbility::Death
        ZombieDruidToken = Token.create "Zombie Druid" do
          creature_type "Zombie Druid"
          power 2
          toughness 2
          colors :black
        end

        def call
          trigger_effect(:create_token, token_class: ZombieDruidToken)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
