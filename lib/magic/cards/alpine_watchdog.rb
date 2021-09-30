module Magic
  module Cards
    AlpineWatchdog = Card("Alpine Watchdog", Creature) do
      type "Creature -- Dog"
      cost generic: 1, white: 1
      power 2
      toughness 2
      keywords Keywords::VIGILANCE
    end
  end
end
