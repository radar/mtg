module Magic
  module Cards
    GreenwoodSentinel = Creature("Greenwood Sentinel") do
      cost generic: 1, green: 1
      creature_type("Elf Scout")
      keywords :vigilance
      power 2
      toughness 2
    end
  end
end
