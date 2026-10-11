module Magic
  module Cards
    RakdosSignet = Artifact("Rakdos Signet") do
      cost generic: 2
    end

    class RakdosSignet < Artifact
      # "{1}, {T}: Add {B}{R}."
      class ManaAbility < Magic::ManaAbility
        costs "{1}, {T}"

        def resolve!
          controller.add_mana(black: 1, red: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
