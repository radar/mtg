module Magic
  module Cards
    BlackLotus = Artifact("Black Lotus") do
      cost generic: 0
    end

    class BlackLotus < Artifact
      class ManaAbility < Magic::ManaAbility
        costs "{T}, Sacrifice {this}"
        choices :all

        def resolve!
          super # Handle choice validation
          # Add 2 more mana (parent adds 1, we need 3 total)
          source.controller.add_mana(choice => 2)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
