module Magic
  module Cards
    SuspiciousShambler = Creature("Suspicious Shambler") do
      cost generic: 3, black: 1
      creature_type("Zombie")
      power 4
      toughness 2
    end

    class SuspiciousShambler < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{4}{B}{B}, Exile {this}"

        activate_from_graveyard_as_sorcery

        ZombieToken = Token.create "Zombie" do
          creature_type "Zombie"
          power 2
          toughness 2
          colors :black
        end

        def resolve!
          trigger_effect(:create_token, token_class: ZombieToken, amount: 2)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
