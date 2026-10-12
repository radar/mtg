module Magic
  module Cards
    BrightbladeStoat = Creature("Brightblade Stoat") do
      cost generic: 1, white: 1
      creature_type("Weasel Soldier")
      keywords :first_strike, :lifelink
      power 2
      toughness 2
    end
  end
end
