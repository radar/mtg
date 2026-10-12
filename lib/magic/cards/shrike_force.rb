module Magic
  module Cards
    ShrikeForce = Creature("Shrike Force") do
      cost generic: 2, white: 1
      creature_type("Bird Knight")
      keywords :flying, :double_strike, :vigilance
      power 1
      toughness 3
    end
  end
end
