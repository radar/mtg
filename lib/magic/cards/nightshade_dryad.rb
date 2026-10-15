module Magic
  module Cards
    NightshadeDryad = Creature("Nightshade Dryad") do
      cost generic: 1, green: 1
      creature_type "Dryad"
      power 1
      toughness 2
      keywords :deathtouch
    end

    class NightshadeDryad < Creature
      # "{T}: Add {C}."
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "{T}: Add one mana of any color."
      class AnyColorManaAbility < Magic::TapManaAbility
        choices :all
      end

      def activated_abilities = [ColorlessManaAbility, AnyColorManaAbility]
    end
  end
end
