module Magic
  module Cards
    WeiInfantry = Creature("Wei Infantry") do
      cost generic: 1, black: 1
      creature_type("Human Soldier")
      power 2
      toughness 1
    end
  end
end