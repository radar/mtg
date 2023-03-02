module Magic
  module Cards
    Watchwolf = Creature("Watchwolf") do
      cost green: 1, white: 1
      creature_type("Wolf")
      power 3
      toughness 3
    end
  end
end