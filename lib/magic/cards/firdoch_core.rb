module Magic
  module Cards
    FirdochCore = Artifact("Firdoch Core") do
      cost generic: 3
      type T::Kindred, T::Artifact, T::Creatures["Shapeshifter"]
      keywords :changeling
    end

    class FirdochCore < Artifact
      class ManaAbility < Magic::TapManaAbility
        choices :all
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{4}"

        def resolve!
          source.become_creature!(power: 4, toughness: 4, types: [T::Artifact])
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
