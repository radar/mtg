module Magic
  module Cards
    ContainmentPriest = Creature("Containment Priest") do
      cost generic: 1, white: 1
      creature_type("Human Cleric")
      keywords :flash
      power 2
      toughness 2
    end
  end
end
