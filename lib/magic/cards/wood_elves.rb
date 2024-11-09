module Magic
  module Cards
    WoodElves = Creature("Wood Elves") do
      power 1
      toughness 1
      creature_type "Elf Scout"
      cost generic: 2, green: 1
    end
  end
end
