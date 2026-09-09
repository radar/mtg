module Magic
  module Cards
    GodEternalBontu = Creature("God-Eternal Bontu") do
      legendary_creature_type "Zombie God"
      cost generic: 3, black: 2
      power 5
      toughness 6
      keywords :menace
    end
  end
end