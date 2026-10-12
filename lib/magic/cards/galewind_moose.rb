module Magic
  module Cards
    GalewindMoose = Creature("Galewind Moose") do
      cost generic: 4, green: 2
      creature_type("Elemental Elk")
      keywords :flash, :reach, :vigilance, :trample
      power 6
      toughness 6
    end
  end
end
