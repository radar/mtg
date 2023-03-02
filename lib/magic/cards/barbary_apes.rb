module Magic
  module Cards
    BarbaryApes = Creature("Barbary Apes") do
      cost generic: 6, green: 3
      creature_type("Ape")
      power 2
      toughness 2
    end
  end
end