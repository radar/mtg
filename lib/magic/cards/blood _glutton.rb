module Magic
  module Cards
    BloodGlutton = Creature("Blood Glutton") do
      cost generic: 4, black: 1
      creature_type "Vampire"
      power 4
      toughness 3
      keywords :lifelink
    end
  end
end
