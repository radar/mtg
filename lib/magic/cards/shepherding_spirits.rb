module Magic
  module Cards
    class ShepherdingSpirits < Creature
      card_name "Shepherding Spirits"
      cost generic: 4, white: 2
      creature_type "Spirit"
      power 4
      toughness 5
      keywords :flying
      # "Plainscycling {2}"
      landcycling({ generic: 2 }, filter: "Plains")
    end
  end
end
