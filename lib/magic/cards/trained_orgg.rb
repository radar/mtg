module Magic
  module Cards
    TrainedOrgg = Creature("Trained Orgg") do
      cost generic: 6, red: 1
      creature_type("Orgg")
      power 6
      toughness 6
    end
  end
end