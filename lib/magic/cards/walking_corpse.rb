module Magic
  module Cards
    WalkingCorpse = Creature("Walking Corpse") do
      creature_type("Zombie")
      cost black: 1, generic: 1
      power 2
      toughness 2
    end
  end
end
