module Magic
  module Cards
    AlabornTrooper = Creature("Alaborn Trooper") do
      cost generic: 2, white: 1
      creature_type("Human Soldier")
      power 2
      toughness 3
    end
  end
end