module Magic
  module Cards
    ChitinousGraspling = Creature("Chitinous Graspling") do
      cost generic: 3, blue_or_green: 1
      creature_type("Shapeshifter")
      keywords :changeling, :reach
      power 3
      toughness 4
    end
  end
end
