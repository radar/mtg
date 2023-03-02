module Magic
  module Cards
    BarbtoothWurm = Creature("Barbtooth Wurm") do
      cost generic: 5, green: 1
      creature_type("Wurm")
      power 6
      toughness 4
    end
  end
end