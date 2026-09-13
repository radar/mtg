module Magic
  module Cards
    MonasterySwiftspear = Creature("Monastery Swiftspear") do
      cost red: 1
      creature_type "Human Monk"
      power 1
      toughness 2
      keywords :haste, :prowess
    end
  end
end
