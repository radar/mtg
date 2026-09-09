module Magic
  module Cards
    CavesOfKoilos = Card("Caves of Koilos") do
      type "Land"
    end

    class CavesOfKoilos < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class ColoredManaAbility < Magic::TapManaAbility
        choices :white, :black

        def resolve!
          super
          controller.lose_life(1)
        end
      end

      def activated_abilities = [ColorlessManaAbility, ColoredManaAbility]
    end
  end
end