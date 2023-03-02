module Magic
  module Cards
    UndeadMinotaur = Creature("Undead Minotaur") do
      cost generic: 2, black: 1
      creature_type(" Zombie Minotaur")
      power 2
      toughness 3
    end
  end
end