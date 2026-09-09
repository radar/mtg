module Magic
  module Cards
    ViridescentBog = Card("Viridescent Bog") do
      type "Land"
    end

    class ViridescentBog < Card
      class ManaAbility < Magic::ManaAbility
        costs "{1}, {T}"

        def resolve!
          controller.add_mana(black: 1, green: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end