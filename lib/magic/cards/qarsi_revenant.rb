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
          add_counter("flying", to: target)
          add_counter("deathtouch", to: target)
          add_counter("lifelink", to: target)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
