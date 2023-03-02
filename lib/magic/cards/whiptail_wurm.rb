module Magic
  module Cards
    WhiptailWurm = Creature("WhiptailWurm") do
      cost generic: 6, green: 1
      creature_type("Wurm")
      power 8
      toughness 5
    end
  end
end