module Magic
  module Cards
    AlchemistsAssistant = Creature("Alchemist's Assistant") do
      cost generic: 1, black: 1
      creature_type("Monkey")
      keywords :lifelink
      power 2
      toughness 1
    end

    class AlchemistsAssistant < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{1}{B}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "lifelink", target: target, amount: 1)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
