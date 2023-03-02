module Magic
  module Cards
    BarbarianHorde = Creature("Barbarian Horde") do
      cost generic: 3, red: 1
      creature_type("Human Barbarian Soldier")
      power 3
      toughness 3
    end
  end
end