module Magic
  module Cards
    WickerWitch = Creature("WickerWitch") do
      cost generic: 3
      creature_type("Scarecrow")
      power 3
      toughness 1
    end
  end
end