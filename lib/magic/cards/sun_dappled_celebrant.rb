module Magic
  module Cards
    SunDappledCelebrant = Creature("Sun-Dappled Celebrant") do
      cost generic: 4, white: 2
      creature_type("Treefolk Cleric")
      keywords :vigilance
      convoke
      power 5
      toughness 6
    end
  end
end
