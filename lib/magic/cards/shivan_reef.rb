module Magic
  module Cards
    ShivanReef = Card("Shivan Reef") do
      type "Land"
    end

    class ShivanReef < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class ColoredManaAbility < Magic::TapManaAbility
        choices :blue, :red

        def resolve!
          super
          controller.lose_life(1)
        end
      end

      def activated_abilities = [ColorlessManaAbility, ColoredManaAbility]
    end
  end
end
