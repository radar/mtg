module Magic
  module Cards
    class FencingAce < Creature
      NAME = "Fencing Ace"
      TYPE_LINE = creature_type("Human Soldier")
      KEYWORDS = [Keywords::DOUBLE_STRIKE]
      POWER = 1
      TOUGHNESS = 1
    end
  end
end
