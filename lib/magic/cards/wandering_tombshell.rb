module Magic
  module Cards
    WanderingTombshell = Creature("Wandering Tombshell") do
      cost generic: 3, black: 1
      creature_type("Zombie Turtle")
      power 1
      toughness 6
    end
  end
end