module Magic
  module Cards
    OrdinaryBear = Creature("Ordinary Bear") do
      cost generic: 3, green: 1
      creature_type("Bear")
      power 4
      toughness 5
    end
  end
end
