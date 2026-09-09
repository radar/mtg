module Magic
  module Cards
    SungrassPrairie = Card("Sungrass Prairie") do
      type "Land"
    end

    class SungrassPrairie < Card
      class ManaAbility < Magic::ManaAbility
        costs "{1}, {T}"

        def resolve!
          controller.add_mana(green: 1, white: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end