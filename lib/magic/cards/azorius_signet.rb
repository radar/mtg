module Magic
  module Cards
    AzoriusSignet = Artifact("Azorius Signet") do
      cost generic: 2
    end

    class AzoriusSignet < Artifact
      class ManaAbility < Magic::ManaAbility
        costs "{1}, {T}"

        def resolve!
          controller.add_mana(white: 1, blue: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
