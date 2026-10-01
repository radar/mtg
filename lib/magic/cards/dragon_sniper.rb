module Magic
  module Cards
    DragonSniper = Creature("Dragon Sniper") do
      cost green: 1
      creature_type("Human Archer")
      keywords :reach, :vigilance, :deathtouch
      power 1
      toughness 1
    end
  end
end
