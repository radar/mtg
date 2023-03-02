module Magic
  module Cards
    BaneAlleyBlackguard = Creature("Bane Alley Blackguard") do
      cost generic: 1, black: 1
      creature_type("Human Rogue")
      power 1
      toughness 3
    end
  end
end