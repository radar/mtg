module Magic
  module Cards
    SunscorchedDivide = Card("Sunscorched Divide") do
      type "Land"
    end

    class SunscorchedDivide < Card
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
