module Magic
  module Cards
    RagingGoblin = Creature("Raging Goblin") do
      type "Creature -- Goblin Beserker"
      cost red: 1
      power 1
      toughness 1
      keywords :haste
    end
  end
end
