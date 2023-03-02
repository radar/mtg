module Magic
  module Cards
    ArmoredWarhorse = Creature("Armored Warhorse") do
      cost generic: 6, green: 3
      creature_type("Horse")
      power 2
      toughness 3
    end
  end
end