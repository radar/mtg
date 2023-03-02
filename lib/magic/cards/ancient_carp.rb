module Magic
  module Cards
    AncientCarp = Creature("Ancient Carp") do
      cost generic: 4, blue: 1
      creature_type("Fish")
      power 2
      toughness 5
    end
  end
end