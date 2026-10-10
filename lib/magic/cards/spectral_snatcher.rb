module Magic
  module Cards
    class SpectralSnatcher < Creature
      card_name "Spectral Snatcher"
      cost generic: 4, black: 2
      creature_type "Spirit"
      power 6
      toughness 5
      ward discard: true
      landcycling({ generic: 2 }, filter: "Swamp")
    end
  end
end
