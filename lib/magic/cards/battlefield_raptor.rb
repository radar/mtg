module Magic
  module Cards
    class BattlefieldRaptor < Creature
      NAME = "Battlefield Raptor"
      KEYWORDS = [Keywords::FLYING, Keywords::FIRST_STRIKE]
      TYPE_LINE = "Creature -- Bird"
      COST = { white: 1 }
      POWER = 1
      TOUGHNESS = 2
    end
  end
end
