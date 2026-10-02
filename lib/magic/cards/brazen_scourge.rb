module Magic
  module Cards
    BrazenScourge = Creature("Brazen Scourge") do
      cost generic: 1, red: 2
      creature_type("Gremlin")
      keywords :haste
      power 3
      toughness 3
    end
  end
end
