module Magic
  module Cards
    AlpineGrizzly = Creature("Alpine Grizzly") do
      cost generic: 2, green: 1
      creature_type("Bear")
      power 4
      toughness 9
    end
  end
end