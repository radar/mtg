module Magic
  module Cards
    class AlpineWatchdog < Creature
      NAME = "Alpine Watchdog"
      TYPE_LINE = "Creature -- Dog"
      COST = { generic: 1, white: 1 }
      POWER = 2
      TOUGHNESS = 2
      KEYWORDS = [Keywords::VIGILANCE]
    end
  end
end
