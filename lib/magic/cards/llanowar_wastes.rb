module Magic
  module Cards
    LlanowarWastes = Card("Llanowar Wastes") do
      type "Land"
    end

    class LlanowarWastes < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class ColoredManaAbility < Magic::TapManaAbility
        choices :black, :green

        def resolve!
          super
          controller.lose_life(1)
        end
      end

      def activated_abilities = [ColorlessManaAbility, ColoredManaAbility]
    end
  end
end