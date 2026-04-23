module Magic
  module Cards
    BlackLotus = Artifact("Black Lotus") do
      cost generic: 0
    end

    class BlackLotus < Artifact
      class ManaAbility < Magic::ManaAbility
        costs "{T}, Sacrifice {this}"
        choices :all
        amount 3
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
