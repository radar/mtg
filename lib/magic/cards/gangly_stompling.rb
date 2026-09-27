module Magic
  module Cards
    GanglyStompling = Creature("Gangly Stompling") do
      cost generic: 2, green_or_red: 1
      creature_type("Shapeshifter")
      keywords :changeling, :trample
      power 4
      toughness 2
    end
  end
end
