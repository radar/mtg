module Magic
  module Cards
    MagnigothSentry = Creature("Magnigoth Sentry") do
      cost generic: 3, green: 1
      creature_type("Treefolk")
      keywords :reach
      power 4
      toughness 4
    end
  end
end
