module Magic
  module Cards
    FerrousLake = Card("Ferrous Lake") do
      type "Land"
    end

    class FerrousLake < Card
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
