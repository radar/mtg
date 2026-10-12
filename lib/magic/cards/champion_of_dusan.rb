module Magic
  module Cards
    ChampionOfDusan = Creature("Champion of Dusan") do
      cost generic: 2, green: 1
      creature_type("Human Warrior")
      keywords :trample
      power 4
      toughness 2
    end

    class ChampionOfDusan < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{1}{G}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          add_counter("+1/+1", to: target)
          add_counter("trample", to: target)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
