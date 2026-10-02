module Magic
  module Cards
    SerraAngel = Creature("Serra Angel") do
      cost generic: 3, white: 2
      creature_type("Angel")
      keywords :flying, :vigilance
      power 4
      toughness 4
    end
  end
end
