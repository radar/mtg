module Magic
  module Cards
    SkycloudExpanse = Card("Skycloud Expanse") do
      type "Land"
    end

    class SkycloudExpanse < Card
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
