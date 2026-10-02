module Magic
  module Cards
    HealersHawk = Creature("Healer's Hawk") do
      cost white: 1
      creature_type("Bird")
      keywords :flying, :lifelink
      power 1
      toughness 1
    end
  end
end
