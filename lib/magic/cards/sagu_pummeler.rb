module Magic
  module Cards
    SaguPummeler = Creature("Sagu Pummeler") do
      cost generic: 3, green: 1
      creature_type("Beast")
      keywords :reach
      power 4
      toughness 4
    end

    class SaguPummeler < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{4}{G}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 2)
          trigger_effect(:add_counter, counter_type: "reach", target: target, amount: 1)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
