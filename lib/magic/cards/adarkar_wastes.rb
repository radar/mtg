module Magic
  module Cards
    AdarkarWastes = Card("Adarkar Wastes") do
      type "Land"
    end

    class AdarkarWastes < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class ColoredManaAbility < Magic::TapManaAbility
        choices :white, :blue

        def resolve!
          super
          controller.lose_life(1)
        end
      end

      def activated_abilities = [ColorlessManaAbility, ColoredManaAbility]
    end
  end
end
