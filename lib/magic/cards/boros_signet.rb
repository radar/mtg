module Magic
  module Cards
    BorosSignet = Artifact("Boros Signet") do
      cost generic: 2
    end

    class BorosSignet < Artifact
      class ManaAbility < Magic::ManaAbility
        costs "{1}, {T}"

        def resolve!
          controller.add_mana(red: 1, white: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
