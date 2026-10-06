module Magic
  module Cards
    IzzetSignet = Artifact("Izzet Signet") do
      cost generic: 2
    end

    class IzzetSignet < Artifact
      class ManaAbility < Magic::ManaAbility
        costs "{1}, {T}"

        def resolve!
          controller.add_mana(blue: 1, red: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
