module Magic
  module Cards
    QuaketuskBoar = Creature("Quaketusk Boar") do
      cost generic: 3, red: 2
      creature_type("Elemental Boar")
      keywords :reach, :trample, :haste
      power 5
      toughness 5
    end
  end
end
