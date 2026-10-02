module Magic
  module Cards
    RagingRedcap = Creature("Raging Redcap") do
      cost generic: 2, red: 1
      creature_type("Goblin Knight")
      keywords :double_strike
      power 1
      toughness 2
    end
  end
end
