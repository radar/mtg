module Magic
  module Cards
    SwabGoblin = Creature("Swab Goblin") do
      cost generic: 1, red: 1
      creature_type("Goblin Pirate")
      power 2
      toughness 2
    end
  end
end
