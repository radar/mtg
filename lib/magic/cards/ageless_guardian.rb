module Magic
  module Cards
    AgelessGuardian = Creature("Ageless Guardian") do
      cost generic: 1, white: 1
      creature_type("Spirit Soldier")
      power 1
      toughness 4
    end
  end
end