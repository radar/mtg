module Magic
  module Cards
    class RagingGoblin < Creature
      NAME = "Raging Goblin"
      COST = { red: 1}
      TYPE_LINE = "Creature -- Goblin Beserker"
      POWER = 1
      TOUGHNESS = 1

      KEYWORDS = [Keywords::HASTE]
    end
  end
end
