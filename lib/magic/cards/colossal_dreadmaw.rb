module Magic
  module Cards
    ColossalDreadmaw = Creature("Colossal Dreadmaw") do
      cost generic: 4, green: 2
      type "Creature -- Dinosaur"
      power 6
      toughness 6
      keywords :trample
    end
  end
end
