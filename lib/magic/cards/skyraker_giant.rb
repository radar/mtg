module Magic
  module Cards
    SkyrakerGiant = Creature("Skyraker Giant") do
      cost generic: 2, red: 2
      creature_type("Giant")
      keywords :reach
      power 4
      toughness 3
    end
  end
end
