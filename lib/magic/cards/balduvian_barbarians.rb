module Magic
  module Cards
    BalduvianBarbarians = Creature("Balduvian Barbarians") do
      cost generic: 1, red: 2
      creature_type("Human Barbarian")
      power 3
      toughness 2
    end
  end
end