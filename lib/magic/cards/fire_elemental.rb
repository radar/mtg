module Magic
  module Cards
    FireElemental = Creature("Fire Elemental") do
      cost generic: 3, red: 2
      creature_type("Elemental")
      power 5
      toughness 4
    end
  end
end
