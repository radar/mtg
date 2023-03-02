module Magic
  module Cards
    WetlandSambar = Creature("Wetland Sambar") do
      cost generic: 1, blue: 1
      creature_type("Elk")
      power 2
      toughness 1
    end
  end
end