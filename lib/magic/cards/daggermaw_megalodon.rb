module Magic
  module Cards
    class DaggermawMegalodon < Creature
      card_name "Daggermaw Megalodon"
      cost generic: 4, blue: 2
      creature_type "Shark"
      power 5
      toughness 7
      keywords :vigilance
      # "Islandcycling {2}"
      landcycling({ generic: 2 }, filter: "Island")
    end
  end
end
