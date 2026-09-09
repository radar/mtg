module Magic
  module Cards
    TwilightMire = Card("Twilight Mire") { type "Land" }

    class TwilightMire < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class HybridManaAbility < Magic::ManaAbility
        costs "{B/G}, {T}"

        def resolve!
          controller.add_mana(black: 1, green: 1)
        end
      end

      def activated_abilities = [ColorlessManaAbility, HybridManaAbility]
    end
  end
end