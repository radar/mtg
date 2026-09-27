module Magic
  module Cards
    PridefulFeastling = Creature("Prideful Feastling") do
      cost generic: 2, black_or_white: 1
      creature_type("Shapeshifter")
      keywords :changeling, :lifelink
      power 2
      toughness 3
    end
  end
end
