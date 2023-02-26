module Magic
  module Cards
    class LoxodonWayfarer < Creature
      NAME = "Loxodon Wayfarer"
      TYPE_LINE = creature_type("Elephant Monk")
      COST = { any: 2, white: 1 }
      POWER = 1
      TOUGHNESS = 5
    end
  end
end
