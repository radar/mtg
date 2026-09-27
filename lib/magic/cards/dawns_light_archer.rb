module Magic
  module Cards
    DawnsLightArcher = Creature("Dawn's Light Archer") do
      cost generic: 2, green: 1
      creature_type("Elf Archer")
      keywords :flash, :reach
      power 4
      toughness 2
    end
  end
end
