module Magic
  module Cards
    BishopsSoldier = Creature("Bishop's Soldier") do
      cost generic: 1, white: 1
      creature_type("Vampire Soldier")
      keywords :lifelink
      power 2
      toughness 2
    end
  end
end
