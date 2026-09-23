module Magic
  module Cards
    AdultGoldDragon = Creature("Adult Gold Dragon") do
      cost generic: 3, red: 1, white: 1
      creature_type("Dragon")
      keywords :flying, :lifelink, :haste
      power 4
      toughness 3
    end
  end
end
