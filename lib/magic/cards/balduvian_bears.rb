module Magic
  module Cards
    BalduvianBears = Creature("Balduvian Bears") do
      cost generic: 1, green: 1
      creature_type("Bear")
      power 2
      toughness 2
    end
  end
end