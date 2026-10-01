module Magic
  module Cards
    QarsiRevenant = Creature("Qarsi Revenant") do
      cost generic: 1, black: 2
      creature_type("Vampire")
      keywords :flying, :deathtouch, :lifelink
      power 3
      toughness 3
    end

    class QarsiRevenant < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{2}{B}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "flying", target: target, amount: 1)
          trigger_effect(:add_counter, counter_type: "deathtouch", target: target, amount: 1)
          trigger_effect(:add_counter, counter_type: "lifelink", target: target, amount: 1)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
