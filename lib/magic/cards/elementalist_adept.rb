module Magic
  module Cards
    ElementalistAdept = Creature("Elementalist Adept") do
      cost generic: 1, blue: 1
      creature_type("Human Wizard")
      keywords :flash, :prowess
      power 2
      toughness 1
    end
  end
end
