module Magic
  module Cards
    WarpathGhoul = Creature("Warpath Ghoul") do
      cost generic: 2, black: 1
      creature_type("Zombie")
      power 3
      toughness 2
    end
  end
end