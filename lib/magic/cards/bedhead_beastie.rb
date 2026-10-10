module Magic
  module Cards
    class BedheadBeastie < Creature
      card_name "Bedhead Beastie"
      cost generic: 4, red: 2
      creature_type "Beast"
      power 5
      toughness 6
      keywords :menace
      landcycling({ generic: 2 }, filter: "Mountain")
    end
  end
end
