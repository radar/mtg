module Magic
  module Cards
    AlpineWatchdog = Creature("Alpine Watchdog") do
      type "Creature -- Dog"
      cost generic: 1, white: 1
      power 2
      toughness 2
      keywords :vigilance
    end
  end
end
