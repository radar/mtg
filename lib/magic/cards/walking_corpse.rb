module Magic
  module Cards
    WalkingCorpse = Creature("Walking Corpse") do
      cost generic: 1, black: 1
      creature_type "Zombie"
      power 2
      toughness 2
    end
  end
end
