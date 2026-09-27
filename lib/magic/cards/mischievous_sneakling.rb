module Magic
  module Cards
    MischievousSneakling = Creature("Mischievous Sneakling") do
      cost generic: 1, black_or_blue: 1
      creature_type("Shapeshifter")
      keywords :changeling, :flash
      power 2
      toughness 2
    end
  end
end
